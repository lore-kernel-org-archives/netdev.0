From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] PKT_SCHED: Provide compat policer stats
	in	action	policer
Date: 20 Dec 2004 09:27:10 -0500
Message-ID: <1103552830.1049.355.camel@jzny.localdomain>
References: <20041215130128.GK8493@postel.suug.ch>
	 <1103119774.1077.74.camel@jzny.localdomain>  <41C05B60.6030504@trash.net>
	 <1103484249.1046.143.camel@jzny.localdomain>  <41C6A6CC.1050105@trash.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-amGTD0YycTBPfRwuI0HL"
Cc: Thomas Graf <tgraf@suug.ch>, "David S. Miller" <davem@davemloft.net>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <41C6A6CC.1050105@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-amGTD0YycTBPfRwuI0HL
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Mon, 2004-12-20 at 05:17, Patrick McHardy wrote:

> > Hopefully with the regression tests in place this will get better.
> 
> On a side-note, you both seem to be inventing your own testing
> framework and regression tests. tcng already includes lots of
> regression tests for tc, tcng and the kernel. Unfortunately,
> last time I checked, it didn't work with 2.6.

I havent looked closely at tcng although Werner has showed it to me a
few times (may be under influence). We need to pick one or other test
setup. I dont care if its what I have, tcng or what Thomas has.
I just stared quickly at what Thomas has and realize its not really
automated. In my case it is easier because i can click on the proverbial
one-button and run 20 tests (including a subset of the policer ones)
and even capturing tcpdumps. I have attached a sample testcase. 
They are harder to create and require the environment i have.
But once you create them, you should be saying "go" - go do something
and come back and get results.
Whatever we end up having, my preference would be something along those
lines,

> > [You fear Murphy less than i - and thats a style difference. Your style
> > is actually more effective in Linux because you can distribute the
> > burden onto users. As a matter of fact it is within Daves tolerance
> > range (but not mine[1]). So you should do just fine]
> 
> I don't feel like I'm distributing burden onto anyone. As I
> said, I run the tests I deem necessary, and I never send out
> patches of whichs correctness I'm not convinced. So far, my
> history of mistakes has been pretty good.

You have been excellent. My statements are more generic than reflect on
you in person. We have probably the highest amount of visible bugs in a
longtime so i hope you understand my concerns.

cheers,
jamal

--=-amGTD0YycTBPfRwuI0HL
Content-Disposition: attachment; filename=M-005-set.tcl
Content-Type: text/x-tcl; name=M-005-set.tcl; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

#!/usr/bin/expect
#
# Pedit Main Test 5
#
# Purpose:  
# To test the pedit/munge/set capabilities.
#
# What it does:
# -Run tcpdump beforehand, and capture a hex dump of a packet.
# -Install a rule stating that any packet that arrives on loopback
# (ingress) and is destined for 127.0.0.1 will be edited.  Offset 0
# will be rewritten to 0x12345678
# -Run tcpdump afterwards, and check the differences between packets
#
# Expected result:
# -The ping will fail, and offset 0 of the packet will contain 0x12345678
#


# Set description for use with libtest
set libtest_description "Pedit action: setting a u32 range at offset 0."
 
# Source common test procedures and run set-up commands
source ./libtest.tcl

# Delete any ingress qdiscs associated with loopback in order to clear state
send "tc qdisc del dev lo ingress\r"

# Send initial pings to establish a base case
send "sleep 1;  ping 127.0.0.1 -c 3 &\r "

# Get a tcpdump hex output for a packet
send "tcpdump -i lo -s 96 -vvv -x host 127.0.0.1 and icmp\[icmptype\]=icmp-echo -c 1\r"
if [expect_tcpdump_results before_list] {
	output_test_failure "Error while expecting tcpdump results"
	return -1
} 

# Add an ingress qdisc
send "tc qdisc add dev lo ingress\r"
 
# Match IP destination 127.0.0.1, and edit these packets to set the 4 octets
# at offset 0 to be 0x12345678
send "tc filter add dev lo parent ffff: protocol ip prio 10 u32 match ip dst 127.0.0.1/32 flowid 1:1 action pedit munge offset 0 u32 set 0x12345678 pipe action mirred egress redirect dev dummy0\r"

# Send a few pings to 127.0.0.1 while tcpdump is running on dummy0 and capture
# the data.
expect -re ".*"
send "sleep 1;  ping 127.0.0.1 -c 2 &\r"

# Get a tcpdump hex output for a packet
send "tcpdump -i dummy0 -s 96 -vvv -x -c 1\r"
if [expect_tcpdump_results after_list] {
        output_test_failure "Error while expecting tcpdump results"
        return -1
} 

# Extra logging
output_test_message "Before: $before_list"
output_test_message "After:  $after_list"

# Check the results.  In this case, data at offsets 0-3 was changed.

# Offsets 0-1 should be 0x1234
if {[lindex $before_list 0] == [lindex $after_list 0]} {
	output_test_failure "Test failed at offsets 0-1"
	return -1
} else {
	if {[lindex $after_list 0] != "1234"} {
		output_test_failure "Test failed at offsets 0-1."
		return -1
	} else {
		output_test_message "Offsets 0-1 changed to 0x1234 (success)"
	}
}

# Offsets 2-3 should be 0x5678
if {[lindex $before_list 1] == [lindex $after_list 1]} {
	output_test_failure "Test failed at offsets 2-3"
	return -1
} else {
	if {[lindex $after_list 1] != "5678"} {
		output_test_failure "Test failed at offsets 2-3"
		return -1
	} else {
		output_test_message "Offsets 2-3 changed to 0x5678 (success)"
	}
}

# Ensure that all expected matching portions of the packet are identical
set exemptions [concat $DEFAULT_TCPDUMP_ICMP_EXEMPTION 0 1]
if [compare_lists $before_list $after_list $exemptions $DEFAULT_TCPDUMP_LENGTH mismatch_index] {
	output_test_failure "Test failed at $mismatch_index"
	return -1
} 

expect -re ".*"
output_test_success
return 0

--=-amGTD0YycTBPfRwuI0HL--
