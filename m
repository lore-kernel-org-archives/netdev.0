From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: Re: [PATCH net v2 5/9] bridge: Fix the way to check if a local fdb
 entry can be deleted
Date: Thu, 30 Jan 2014 21:50:07 +0900
Message-ID: <1391086207.3565.37.camel@ubuntu-vm-makita>
References: <1387281821-21342-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
	 <1387281821-21342-6-git-send-email-makita.toshiaki@lab.ntt.co.jp>
	 <52B09DB2.7040700@redhat.com> <1387341972.3563.71.camel@ubuntu-vm-makita>
	 <52B1D9E6.7020201@redhat.com> <1387455834.4084.47.camel@ubuntu-vm-makita>
	 <20131219093921.449c5d62@nehalam.linuxnetplumber.net>
	 <1387526576.3475.5.camel@ubuntu-vm-makita>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>,
	vyasevic@redhat.com, "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tama50.ecl.ntt.co.jp ([129.60.39.147]:43509 "EHLO
	tama50.ecl.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752698AbaA3MuY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jan 2014 07:50:24 -0500
In-Reply-To: <1387526576.3475.5.camel@ubuntu-vm-makita>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-12-20 at 17:02 +0900, Toshiaki Makita wrote:
> On Thu, 2013-12-19 at 09:39 -0800, Stephen Hemminger wrote:
> ...
> > Could we make up as set of test case scripts to validate these changes.
> > Now that FDB table can be manipulated by iproute tools, should be possible
> > to have set of cases for validation.
> 
> Thank you for your suggestion.
> Maybe is it enough to make some test of port attach/detach and confirm
> that data/control plane doesn't result in any inconsistency or odd
> situation by tcpdump/bridge commands?

Sorry for replying an old thread..

I tested traffic and fdb entries when attaching/detaching a bridge port,
and couldn't find any problem with this patch.

Instead, I found an additional undesirable behavior without this patch:
ping to a bridge device (with arp resolution) sometimes fails while
detaching a port.
The bridge device continues to have its mac address for a while when a
port is detached, but in current implementation we immediately delete
corresponding fdb entry even though that mac address is used by the
bridge device. I think this caused ping fails because the replied mac
address actually can't reach the bridge device due to the premature fdb
entry deletion.

I need to rearrange this patch set, but I'm going to keep this change as
is.


The test I did is:
- Attach/detach a port while sending traffic, and confirm tat the
traffic is changed to being [flooded/delivered to the bridge] as
expected. Also, confirm that corresponding fdb entry is added/deleted as
expected.
- Attach/detach a port while flushing arp entry and pinging, and confirm
that ping doesn't fail.

The test script I used and the result is below.

---- Test script begin ----
#!/bin/sh

# This is a test script for validating fdb and traffic consistency
# when a bridge port is attached/detached.
#
# This script does two types of tests.
# Forwarding test:
#   Confirm that traffic to mac address of PORT0 is delivered to bridge
#   when PORT0 is attached and flooded when PORT0 is detached.
#   And measure the time window between "ip set master" and actual traffic
#   change by "date" command (clock_gettime) and timestamp in tcpdump.
# ARP/ICMP test:
#   Confirm that ping can always suceed with arp resolution each time when
#   PORT0 gets attached/detached.
# In each test, this validates fdb entries as well, i.e. if attaching PORT0,
# we must have a local entry where its dst and address is those of PORT0,
# and if detaching PORT0, we must not have such an entry.
#
# This test script assumes environment below.
# BR0 has three ports. Two of them (PORT1/2) are veths to namespaces.
# PORT0 is subject for attaching/detaching.
#
# +----------------------------------------------+
# | +-------------+                              |
# | |     +-------|        +-----+  +---+  +-----|
# | | NS0 |NS0_IF0|--VETH--|PORT1|--|BR0|--|PORT0|
# | |     +-------|        +-----+  +---+  +-----|
# | +-------------+                   |          |
# |                                   |          |
# | +-------------+                   |          |
# | |     +-------|        +-----+    |          |
# | | NS1 |NS1_IF0|--VETH--|PORT2|----+          |
# | |     +-------|        +-----+               |
# | +-------------+                              |
# |                             Physical machine |
# +----------------------------------------------+
#
# Test scenarios are
# Forwarding test:
#   Send traffic from NS0 to the mac address of PORT0.
#   The traffic should be delivered to BR0 when attached, and to NS1 when
#   detached.
# ARP/ICMP test:
#   Invalidate the arp entry of the mac address of PORT0 and do "ping -c 1"
#   to the ip address of BR0.
#   Ping should always succeed even if attach/detach occurs.

export LC_ALL=C

# Number of tests
ITERATIONS=10
[ -n "$1" ] && ITERATIONS=$1

# Namespace
NS0=ns0
NS1=ns1
NS0CMD="ip netns exec $NS0"

# Veth interface
VETH_TO_NS0_IF=veth0
NS0_IF=ns0-eth0
VETH_TO_NS1_IF=veth1
NS1_IF=ns1-eth0

# Bridge
BR0=br0

# Bridge interfaces
PORT0=em1
PORT1=$VETH_TO_NS0_IF
PORT2=$VETH_TO_NS1_IF

# MAC addresses
MAC0=12:34:56:78:90:ab # for PORT0, smallest among all bridge ports
NS0_MAC=aa:bb:cc:dd:ee:00
NS1_MAC=aa:bb:cc:dd:ee:01
FLOOD_MAC=aa:bb:cc:dd:ee:02

# IP addresses
BR0_IP=192.168.0.1
NS0_IP=192.168.0.2
PREFIX=24

# Pktgen parameters
PGTHREAD=/proc/net/pktgen/kpktgend_0
PGDEV=/proc/net/pktgen/$NS0_IF
PGCTRL=/proc/net/pktgen/pgctrl

# Directories to store logs
RESULT_DIR=/tmp

# Test statistics
SEND_FAILS_ATTACH=0
NO_ENTRY_ATTACH=0
WRONG_ENTRY_ATTACH=0
UNDELETED_ENTRY_ATTACH=0
CAPTURE_DROPS_ATTACH=0
NO_CAPTURE_ATTACH=0
DELAYED_FLOW_CHANGE_ATTACH=0
DROPS_UNKNOWN_REASON_ATTACH=0

SEND_FAILS_DETACH=0
NO_ENTRY_DETACH=0
WRONG_ENTRY_DETACH=0
UNDELETED_ENTRY_DETACH=0
CAPTURE_DROPS_DETACH=0
NO_CAPTURE_DETACH=0
DELAYED_FLOW_CHANGE_DETACH=0
DROPS_UNKNOWN_REASON_DETACH=0

WINDOW_SUM_ATTACH=0
WINDOW_MAX_ATTACH=0
WINDOW_MIN_ATTACH=-1

WINDOW_SUM_DETACH=0
WINDOW_MAX_DETACH=0
WINDOW_MIN_DETACH=-1

PING_FAIL_COUNT_ATTACH=0
PING_ERROR_COUNT_ATTACH=0
PING_FAIL_COUNT_DETACH=0
PING_ERROR_COUNT_DETACH=0

FORWARD_TEST_COUNT_ATTACH=0
FORWARD_TEST_COUNT_DETACH=0
REPLY_TEST_COUNT_ATTACH=0
REPLY_TEST_COUNT_DETACH=0

prepare ()
{
	modprobe pktgen

	# Namespace settings
	for i in 0 1; do
		eval NS=\$NS$i
		eval NS_IF=\$NS${i}_IF
		eval VETH_TO_NS_IF=\$VETH_TO_NS${i}_IF
		eval NS_MAC=\$NS${i}_MAC

		if ip netns | grep -q $NS; then
			ip netns exec $NS ip link show dev $NS_IF > /dev/null 2>&1 && \
			ip netns exec $NS ip link del $NS_IF
			ip netns del $NS
		fi

		ip netns add $NS

		ip link show dev $VETH_TO_NS_IF > /dev/null 2>&1 && \
		ip link del $VETH_TO_NS_IF
		ip link show dev $NS_IF > /dev/null 2>&1 && ip link del $NS_IF
		ip link add $VETH_TO_NS_IF type veth peer name $NS_IF

		ip link set $NS_IF netns $NS
		ip netns exec $NS ip link set $NS_IF up
		ip link set $VETH_TO_NS_IF address $NS_MAC 
	done

	# PORT0 address setting
	ip link set $PORT0 address $MAC0

	# Bridge settings
	ip link show dev $BR0 > /dev/null 2>&1 && ip link del $BR0
	ip link add $BR0 type bridge

	ip link set $PORT1 master $BR0 # NS0
	ip link set $PORT2 master $BR0 # NS1

	# IP address settings
	ip addr add ${BR0_IP}/$PREFIX dev $BR0
	$NS0CMD ip addr add ${NS0_IP}/$PREFIX dev $NS0_IF

	# Enable bridge and ports
	ip link set $PORT0 up
	ip link set $PORT1 up
	ip link set $PORT2 up
	ip link set $BR0 up
}

# Set a pktgen parameter
pgset ()
{
	PGPATH=$2
	if [ x"$3" == x"bg" -a x"$PGPATH" == x"$PGCTRL" ]; then
		$NS0CMD sh -c "echo $1 > $PGPATH" &
		PG_PID=$!
		ERROR=$?
	else
		$NS0CMD sh -c "echo $1 > $PGPATH"
		ERROR=$?
		RESULT=`$NS0CMD cat $PGPATH`
		if ! echo "$RESULT" | fgrep -q "Result: OK:"; then
			echo "$RESULT" | fgrep Result: 1>&2
			ERROR=1
		fi
	fi
	[ $ERROR -ne 0 ] && return 1
	return 0
}

# Send frames using pktgen
send_frames ()
{
	COUNT=$1
	DST=$2
	BG=$3

	pgset "rem_device_all" $PGTHREAD || return 1
	pgset "add_device $NS0_IF" $PGTHREAD || return 1
	
	pgset "count $COUNT" $PGDEV || return 1
	pgset "pkt_size 60" $PGDEV || return 1
	pgset "dst_mac $DST" $PGDEV || return 1
	pgset "delay 0" $PGDEV || return 1

	pgset "start" $PGCTRL $BG || return 1
	return 0
}

# Send frames and attach/detach PORT0
do_forward_test ()
{
	ATTACH=$1
	if [ x"$ATTACH" == x"attach" ]; then
		MASTER="master $BR0"
	else
		MASTER="nomaster"
	fi

	DUMP_PROG=tcpdump
	DATE=`date +%H%M%S%N`
	BR0_DUMP=${RESULT_DIR}/${BR0}_${DATE}.dump
	BR0_DUMPLOG=${RESULT_DIR}/${BR0}_${DATE}.log
	NS1_IF_DUMP=${RESULT_DIR}/${NS1_IF}_${DATE}.dump
	NS1_IF_DUMPLOG=${RESULT_DIR}/${NS1_IF}_${DATE}.log
	FILTER="udp and dst port 9"

	# Start capturing
	$DUMP_PROG -p -i $BR0 -f "$FILTER" -s 64 \
	-w $BR0_DUMP 2> $BR0_DUMPLOG &
	DUMP_PIDS=$!

	ip netns exec $NS1 $DUMP_PROG -p -i $NS1_IF -f "$FILTER" -s 64 \
	-w $NS1_IF_DUMP 2> $NS1_IF_DUMPLOG &
	DUMP_PIDS="$DUMP_PIDS $!"

	# Wait for capturing start
	BR0_CAPTURE_OK=0
	NS1_IF_CAPTURE_OK=0
	while [ $BR0_CAPTURE_OK -eq 0 -o $NS1_IF_CAPTURE_OK -eq 0 ]; do
		[ $BR0_CAPTURE_OK -eq 0 ] &&  send_frames 1000 "$NS0_MAC" fg
		[ $NS1_IF_CAPTURE_OK -eq 0 ] && send_frames 1000 "$FLOOD_MAC" fg
		sleep 0.2
		[ $BR0_CAPTURE_OK -eq 0 ] && \
		[ `tshark -n -r $BR0_DUMP 2> /dev/null | wc -l` -ne 0 ] && \
		BR0_CAPTURE_OK=1
		[ $NS1_IF_CAPTURE_OK -eq 0 ] && \
		[ `tshark -n -r $NS1_IF_DUMP 2> /dev/null | wc -l` -ne 0 ] && \
		NS1_IF_CAPTURE_OK=1
	done

	# Do test
	PG_PID=""
	if send_frames 0 "$MAC0" bg; then
		# Wait for frame sending start
		sleep 0.2

		# Change traffic destination
		ADD_DEL_IF_TIME=`date +%H%M%S%N`
		ip link set $PORT0 $MASTER

		# Wait for traffic flow change
		sleep 0.1

		SEND_FAILED=0
	else
		SEND_FAILED=1
	fi

	# Stop capturing
	kill $DUMP_PIDS $PG_PID
	wait $DUMP_PIDS $PG_PID 2> /dev/null
	DUMP_PIDS=""
	PG_PID=""

	if [ $SEND_FAILED -eq 0 ]; then
		SEND_ERROR_COUNT=`$NS0CMD tail -1 $PGDEV | \
		sed -n 's/.*errors: \([0-9]\+\)/\1/p'`
		[ "$SEND_ERROR_COUNT" -ne 0 ] && SEND_FAILED=1
	fi
}

validate_fdb ()
{
	local AT_TYPE=$1

	FDB_ENTRY=`bridge fdb show | grep -v self | grep $MAC0`
	if [ -z "$FDB_ENTRY" ]; then
		# Retrieving a particular fdb entry might fail because
		# "bridge fdb show" could consist of multiple netlink
		# recvmsg()s and fdb might changes between each recvmsg().
		# Check fdb again to make sure.
		FDB_ENTRY=`bridge fdb show | grep -v self | grep $MAC0`
	fi

	if [ x"$AT_TYPE" == x"ATTACH" ]; then
		if [ -z "$FDB_ENTRY" ]; then
			NO_ENTRY_ATTACH=`expr $NO_ENTRY_ATTACH + 1`
			return 1
		fi
	
		if ! echo $FDB_ENTRY | grep -q "permanent"; then
			WRONG_ENTRY_ATTACH=`expr $WRONG_ENTRY_ATTACH + 1`
			return 1
		fi
		if ! echo $FDB_ENTRY | grep -q "$PORT0"; then
			WRONG_ENTRY_ATTACH=`expr $WRONG_ENTRY_ATTACH + 1`
			return 1
		fi
	else
		if [ -n "$FDB_ENTRY" ]; then
			if ! echo $FDB_ENTRY | grep -q "$PORT0"; then
				WRONG_ENTRY_DETACH=`expr $WRONG_ENTRY_DETACH + 1`
				return 1
			fi
			UNDELETED_ENTRY_DETACH=`expr $UNDELETED_ENTRY_DETACH + 1`
			return 1
		fi
	fi

	return 0
}

validate_forward ()
{
	if [ x"$1" == x"attach" ]; then
		DUMP_BEFORE_CHANGE=$NS1_IF_DUMP
		DUMP_AFTER_CHANGE=$BR0_DUMP
		local AT_TYPE="ATTACH"
	else
		DUMP_BEFORE_CHANGE=$BR0_DUMP
		DUMP_AFTER_CHANGE=$NS1_IF_DUMP
		local AT_TYPE="DETACH"
	fi

	if [ $SEND_FAILED -eq 1 ]; then
		eval local SEND_FAILS=\$SEND_FAILS_$AT_TYPE
		eval SEND_FAILS_$AT_TYPE=`expr $SEND_FAILS + 1`
		return 2
	fi

	validate_fdb $AT_TYPE
	local RET=$?
	[ $RET -ne 0 ] && return $RET

	# Validate captured data
	BR0_CAPTURE_DROPS=`tail -1 $BR0_DUMPLOG | awk '{print $1}'`
	NS1_IF_CAPTURE_DROPS=`tail -1 $NS1_IF_DUMPLOG | awk '{print $1}'`
	if [ "$BR0_CAPTURE_DROPS" -ne 0 -o \
	     "$NS1_IF_CAPTURE_DROPS" -ne 0 ]; then
		# Kernel failed to store captured frames due to no space
		eval local CAPTURE_DROPS=\$CAPTURE_DROPS_$AT_TYPE
		eval CAPTURE_DROPS_$AT_TYPE=`expr $CAPTURE_DROPS + 1`
		return 2
	fi

	CAPTURED_BEFORE_CHANGE=`tshark -n -r $DUMP_BEFORE_CHANGE -T fields \
	-e frame.number -Y "eth.dst eq $MAC0" 2> /dev/null | wc -l`
	CAPTURED_AFTER_CHANGE=`tshark -n -r $DUMP_AFTER_CHANGE -T fields \
	-e frame.number -Y "eth.dst eq $MAC0" 2> /dev/null | wc -l`
	if [ $CAPTURED_BEFORE_CHANGE -eq 0 ]; then
		# Couldn't captured expected traffic
		# Maybe one of 'sleep's was too short
		eval local NO_CAPTURE=\$NO_CAPTURE_$AT_TYPE
		eval NO_CAPTURE_$AT_TYPE=`expr $NO_CAPTURE + 1`
		return 2
	fi
	if [ $CAPTURED_AFTER_CHANGE -eq 0 ]; then
		# This implies too late traffic flow change
		eval local DELAYED_FLOW_CHANGE=\$DELAYED_FLOW_CHANGE_$AT_TYPE
		eval DELAYED_FLOW_CHANGE_$AT_TYPE=`expr $DELAYED_FLOW_CHANGE + 1`
		return 1
	fi

	LAST_SEQ_BEFORE_CHANGE=`tshark -n -r $DUMP_BEFORE_CHANGE -T fields \
	-e pktgen.seqnum -Y "eth.dst eq $MAC0" 2> /dev/null | tail -1`
	FIRST_SEQ_AFTER_CHANGE=`tshark -n -r $DUMP_AFTER_CHANGE -T fields \
	-e pktgen.seqnum -Y "eth.dst eq $MAC0" 2> /dev/null | head -1`
	LAST_SEQ_AFTER_CHANGE=`tshark -n -r $DUMP_AFTER_CHANGE -T fields \
	-e pktgen.seqnum -Y "eth.dst eq $MAC0" 2> /dev/null | tail -1`

	# Check drops by unknown reason
	if [ `expr $FIRST_SEQ_AFTER_CHANGE - $LAST_SEQ_BEFORE_CHANGE` -ne 1 -o \
	     "$CAPTURED_BEFORE_CHANGE" -ne "$LAST_SEQ_BEFORE_CHANGE" -o \
	     "$CAPTURED_AFTER_CHANGE" -ne \
	     `expr $LAST_SEQ_AFTER_CHANGE - $LAST_SEQ_BEFORE_CHANGE` ]; then
		eval local DROPS_UNKNOWN_REASON=\$DROPS_UNKNOWN_REASON_$AT_TYPE
		eval DROPS_UNKNOWN_REASON_$AT_TYPE=`expr $DROPS_UNKNOWN_REASON + 1`
		return 1
	fi

	# Calculate window time
	TRAFFIC_CHANGED_TIME=`tshark -n -r $DUMP_AFTER_CHANGE -T fields \
	-e frame.time -Y "eth.dst eq $MAC0" 2> /dev/null | head -1 | \
	awk '{print $4}' | sed s/[:.]//g`

	h1=`echo $ADD_DEL_IF_TIME | cut -b 1-2`
	m1=`echo $ADD_DEL_IF_TIME | cut -b 3-4`
	s1=`echo $ADD_DEL_IF_TIME | cut -b 5-6`
	us1=`echo $ADD_DEL_IF_TIME | cut -b 7-12`
	TIME1=`expr $h1 \* 3600 + $m1 \* 60 + $s1`
	TIME1=`expr $TIME1 \* 1000000 + $us1`

	h2=`echo $TRAFFIC_CHANGED_TIME | cut -b 1-2`
	[ "$h2" -lt "$h1" ] && h2=`expr $h2 + 24`
	m2=`echo $TRAFFIC_CHANGED_TIME | cut -b 3-4`
	s2=`echo $TRAFFIC_CHANGED_TIME | cut -b 5-6`
	us2=`echo $TRAFFIC_CHANGED_TIME | cut -b 7-12`
	TIME2=`expr $h2 \* 3600 + $m2 \* 60 + $s2`
	TIME2=`expr $TIME2 \* 1000000 + $us2`

	WINDOW=`expr $TIME2 - $TIME1`
	eval local WINDOW_SUM=\$WINDOW_SUM_$AT_TYPE
	eval WINDOW_SUM_$AT_TYPE=`expr $WINDOW_SUM + $WINDOW`
	eval local WINDOW_MAX=\$WINDOW_MAX_$AT_TYPE
	[ "$WINDOW" -gt "$WINDOW_MAX" ] && eval WINDOW_MAX_$AT_TYPE=$WINDOW
	eval local WINDOW_MIN=\$WINDOW_MIN_$AT_TYPE
	[ "$WINDOW_MIN" -eq -1 -o "$WINDOW" -lt "$WINDOW_MIN" ] && \
	eval WINDOW_MIN_$AT_TYPE=$WINDOW

	return 0
}

cleanup_forward_logs ()
{
	/bin/rm -f "$BR0_DUMP"
	/bin/rm -f "$BR0_DUMPLOG"
	/bin/rm -f "$NS1_IF_DUMP"
	/bin/rm -f "$NS1_IF_DUMPLOG"
}

send_probes ()
{
	: > $PROBE_RESULT
	while :; do
		# Invalidate arp cache
		$NS0CMD ip neigh del $BR0_IP dev $NS0_IF 2> /dev/null
		# Send arp request and echo request.
		# This may fail when mac address of BR0 changes
		# between arp reply and echo request.
		$NS0CMD ping -c 1 -w 1 $BR0_IP > /dev/null 2>&1 || \
		echo >> $PROBE_RESULT
	done
}

do_reply_test ()
{
	ATTACH=$1
	if [ x"$ATTACH" == x"attach" ]; then
		MASTER="master $BR0"
	else
		MASTER="nomaster"
	fi

	DATE=`date +%H%M%S%N`
	PROBE_RESULT=${RESULT_DIR}/PROBE_${DATE}.log

	send_probes &
	PROBE_PID=$!
	sleep 0.1

	# Change traffic destination
	ip link set $PORT0 $MASTER

	# Wait for traffic flow change
	sleep 1.2

	# Stop probing
	kill $PROBE_PID
	wait $PROBE_PID 2> /dev/null
	PROBE_PID=""
}

validate_reply ()
{
	if [ x"$1" == x"attach" ]; then
		local AT_TYPE="ATTACH"
	else
		local AT_TYPE="DETACH"
	fi

	validate_fdb $AT_TYPE
	local RET=$?
	[ $RET -ne 0 ] && return $RET

	# validate ping result
	local PING_FAIL=`cat $PROBE_RESULT | wc -l`
	if [ $PING_FAIL -eq 1 ]; then
		# ping may fail if mac address changes between arp reply and
		# echo request.
		eval local PING_FAIL_COUNT=\$PING_FAIL_COUNT_$AT_TYPE
		eval PING_FAIL_COUNT_$AT_TYPE=`expr $PING_FAIL_COUNT + 1`
		return 2
	elif [ $PING_FAIL -gt 1 ]; then
		# ping should not fail two or more times.
		eval local PING_ERROR_COUNT=\$PING_ERROR_COUNT_$AT_TYPE
		eval PING_ERROR_COUNT_$AT_TYPE=`expr $PING_ERROR_COUNT + 1`
		return 1
	fi

	return 0
}

cleanup_reply_logs ()
{
	/bin/rm -f "$PROBE_RESULT"
}

output_results ()
{
	echo "" 1>&2

	local AT_TYPE
	for AT_TYPE in ATTACH DETACH; do
		eval local NO_ENTRY=\$NO_ENTRY_$AT_TYPE
		eval local WRONG_ENTRY=\$WRONG_ENTRY_$AT_TYPE
		eval local UNDELETED_ENTRY=\$UNDELETED_ENTRY_$AT_TYPE
		eval local DELAYED_FLOW_CHANGE=\$DELAYED_FLOW_CHANGE_$AT_TYPE
		eval local DROPS_UNKNOWN_REASON=\$DROPS_UNKNOWN_REASON_$AT_TYPE
		eval local PING_ERROR_COUNT=\$PING_ERROR_COUNT_$AT_TYPE
		ERROR_COUNT=`expr $NO_ENTRY + $WRONG_ENTRY + $UNDELETED_ENTRY + $DELAYED_FLOW_CHANGE + $DROPS_UNKNOWN_REASON + $PING_ERROR_COUNT`

		eval local SEND_FAILS=\$SEND_FAILS_$AT_TYPE
		eval local CAPTURE_DROPS=\$CAPTURE_DROPS_$AT_TYPE
		eval local NO_CAPTURE=\$NO_CAPTURE_$AT_TYPE
		eval local PING_FAIL_COUNT=\$PING_FAIL_COUNT_$AT_TYPE
		INFO_COUNT=`expr $SEND_FAILS + $CAPTURE_DROPS + $NO_CAPTURE + $PING_FAIL_COUNT`

		eval local FORWARD_TEST_COUNT=\$FORWARD_TEST_COUNT_$AT_TYPE
		eval local REPLY_TEST_COUNT=\$REPLY_TEST_COUNT_$AT_TYPE
		local TEST_COUNT=`expr $FORWARD_TEST_COUNT + $REPLY_TEST_COUNT`

		echo "$AT_TYPE test result:"
		if [ "$ERROR_COUNT" -ne 0 ]; then
			echo "Validation failed: $ERROR_COUNT"
			if [ "$NO_ENTRY" -ne 0 ]; then
				echo -e "\tExpected fdb entry not found: $NO_ENTRY"
			fi
			if [ "$WRONG_ENTRY" -ne 0 ]; then
				echo -e "\tExpected fdb entry had wrong attribute: $WRONG_ENTRY"
			fi
			if [ "$UNDELETED_ENTRY" -ne 0 ]; then
				echo -e "\tUnexpected fdb entry found: $UNDELETED_ENTRY"
			fi
			if [ "$DELAYED_FLOW_CHANGE" -ne 0 ]; then
				echo -e "\tWindow time was too long (over 100 ms): $DELAYED_FLOW_CHANGE"
			fi
			if [ "$DROPS_UNKNOWN_REASON" -ne 0 ]; then
				echo -e "\tCouldn't capture due to unknown reason: $DROPS_UNKNOWN_REASON"
			fi
			if [ "$PING_ERROR_COUNT" -ne 0 ]; then
				echo -e "\tPing failed two or more times: $PING_ERROR_COUNT"
			fi
		else
			if [ "$TEST_COUNT" -ne 0 ]; then
				echo "All validations succeeded."
				echo "Number of valid tests: $TEST_COUNT"
				echo -e "\tForwarding tests: $FORWARD_TEST_COUNT"
				echo -e "\tARP/ICMP tests: $REPLY_TEST_COUNT"
			else
				echo "No valid test was done."
			fi
		fi

		if [ "$FORWARD_TEST_COUNT" -ne 0 ]; then
			eval local WINDOW_SUM=\$WINDOW_SUM_$AT_TYPE
			eval local WINDOW_MAX=\$WINDOW_MAX_$AT_TYPE
			eval local WINDOW_MIN=\$WINDOW_MIN_$AT_TYPE

			echo "Window time summary:"

			WINDOW_AVG=`expr $WINDOW_SUM / $FORWARD_TEST_COUNT`
			WINDOW_AVG_MSEC=`expr $WINDOW_AVG / 1000`
			WINDOW_AVG_USEC=`expr $WINDOW_AVG % 1000 | xargs printf %03d`
			echo -e "\tAverage window time: ${WINDOW_AVG_MSEC}.$WINDOW_AVG_USEC msec"

			WINDOW_MAX_MSEC=`expr $WINDOW_MAX / 1000`
			WINDOW_MAX_USEC=`expr $WINDOW_MAX % 1000 | xargs printf %03d`
			echo -e "\tMax window time: ${WINDOW_MAX_MSEC}.$WINDOW_MAX_USEC msec"

			WINDOW_MIN_MSEC=`expr $WINDOW_MIN / 1000`
			WINDOW_MIN_USEC=`expr $WINDOW_MIN % 1000 | xargs printf %03d`
			echo -e "\tMin window time: ${WINDOW_MIN_MSEC}.$WINDOW_MIN_USEC msec"
		fi

		if [ "$INFO_COUNT" -ne 0 ]; then
			echo "INFO: Some tests failed to execute commands normally."
			echo "      These are not validation failures but test environment issues."
			if [ "$SEND_FAILS" -ne 0 ]; then
				echo -e "\tFrame send fails: $SEND_FAILS"
			fi
			if [ "$CAPTURE_DROPS" -ne 0 ]; then
				echo -e "\tCouldn't capture due to buffer overflow: $CAPTURE_DROPS"
			fi
			if [ "$NO_CAPTURE" -ne 0 ]; then
				echo -e "\tCouldn't capture due to delayed pktgen start: $NO_CAPTURE"
			fi
			if [ "$PING_FAIL_COUNT" -ne 0 ]; then
				echo -e "\tPing failed (only once): $PING_FAIL_COUNT"
				echo -e "\t  Maybe this happened due to timing issue where mac address changes between arp reply and echo request."
			fi
		fi

		echo ""
	done
}

cleanup_settings ()
{
	ip link del $BR0

	local i
	for i in 0 1; do
		eval NS=\$NS$i
		eval VETH_TO_NS_IF=\$VETH_TO_NS${i}_IF

		ip link del $VETH_TO_NS_IF
		ip netns del $NS
	done
}

output_exit ()
{
	output_results
	if [ -n "$DUMP_PIDS$PG_PID$PROBE_PID" ]; then
		kill $DUMP_PIDS $PG_PID $PROBE_PID
		wait $DUMP_PIDS $PG_PID $PROBE_PID 2> /dev/null
	fi
	cleanup_forward_logs
	cleanup_reply_logs
	cleanup_settings
	exit
}

forward_test ()
{
	local j
	for j in attach detach; do
		if [ x"$j" == x"attach" ]; then
			local AT_TYPE=ATTACH
		else
			local AT_TYPE=DETACH
		fi
		do_forward_test $j
		validate_forward $j
		local RET=$?
		if [ $RET -eq 0 ]; then
			echo -n "." 1>&2
			eval local TEST_COUNT=\$FORWARD_TEST_COUNT_$AT_TYPE
			eval FORWARD_TEST_COUNT_$AT_TYPE=`expr $TEST_COUNT + 1`
		elif [ $RET -eq 1 ]; then
			echo -n "!" 1>&2
		else
			echo -n "?" 1>&2
		fi
		cleanup_forward_logs
	done
}

reply_test ()
{
	local j
	for j in attach detach; do
		if [ x"$j" == x"attach" ]; then
			local AT_TYPE=ATTACH
		else
			local AT_TYPE=DETACH
		fi
		do_reply_test $j
		validate_reply $j
		local RET=$?
		if [ $RET -eq 0 ]; then
			echo -n "." 1>&2
			eval local TEST_COUNT=\$REPLY_TEST_COUNT_$AT_TYPE
			eval REPLY_TEST_COUNT_$AT_TYPE=`expr $TEST_COUNT + 1`
		elif [ $RET -eq 1 ]; then
			echo -n "!" 1>&2
		else
			echo -n "?" 1>&2
		fi
		cleanup_reply_logs
	done
}

prepare

trap output_exit INT TERM
trap "output_results 1>&2" USR1

for i in `seq $ITERATIONS`; do
	forward_test
	reply_test
done

output_exit

---- Test script end ----

---- Test result begin ----

* before this patch set

ATTACH test result:
All validations succeeded.
Number of valid tests: 2000
        Forwarding tests: 1000
        ARP/ICMP tests: 1000
Window time summary:
        Average window time: 1.547 msec
        Max window time: 2.899 msec
        Min window time: 1.328 msec

DETACH test result:
All validations succeeded.
Number of valid tests: 1982
        Forwarding tests: 1000
        ARP/ICMP tests: 982
Window time summary:
        Average window time: 1.276 msec
        Max window time: 4.030 msec
        Min window time: 1.056 msec
INFO: Some tests failed to execute commands normally.
      These are not validation failures but test environment issues.
        Ping failed (only once): 18
          Maybe this happened due to timing issue where mac address changes between arp reply and echo request.


* after this patch set

ATTACH test result:
All validations succeeded.
Number of valid tests: 2000
        Forwarding tests: 1000
        ARP/ICMP tests: 1000
Window time summary:
        Average window time: 1.455 msec
        Max window time: 2.651 msec
        Min window time: 1.256 msec

DETACH test result:
All validations succeeded.
Number of valid tests: 1999
        Forwarding tests: 1000
        ARP/ICMP tests: 999
Window time summary:
        Average window time: 1.382 msec
        Max window time: 4.015 msec
        Min window time: 1.159 msec
INFO: Some tests failed to execute commands normally.
      These are not validation failures but test environment issues.
        Ping failed (only once): 1
          Maybe this happened due to timing issue where mac address changes between arp reply and echo request.

---- Test result end ----

Note: ping failed only once even after applying this patch set.
I'm thinking mac address was changed between arp reply and echo request.
This can happen on not only bridge device but also in any network
environment, and not a bug.

Thanks,
Toshiaki Makita
