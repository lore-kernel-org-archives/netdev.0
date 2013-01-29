From: Tom Parkin <tparkin@katalix.com>
Subject: kmemleak complaints in ip6mr.c
Date: Tue, 29 Jan 2013 18:51:27 +0000
Message-ID: <20130129185127.GA31811@raven>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="PNTmBPCT7hxwcZjr"
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:52144 "EHLO mail.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751143Ab3A2Svc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Jan 2013 13:51:32 -0500
Received: from localhost (cpc28-brad20-2-0-cust174.17-1.cable.virginmedia.com [77.97.157.175])
	(using TLSv1 with cipher DHE-RSA-AES128-SHA (128/128 bits))
	(No client certificate requested)
	(Authenticated sender: tom)
	by mail.katalix.com (Postfix) with ESMTPSA id 30E40A620CA
	for <netdev@vger.kernel.org>; Tue, 29 Jan 2013 18:51:28 +0000 (GMT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--PNTmBPCT7hxwcZjr
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

I've discovered what may be a memory leak in ip6mr when using network
namespaces.  Here's the kmemleak backtrace:


unreferenced object 0xf0d4a180 (size 96):
  comm "ip", pid 6735, jiffies 4294949643 (age 73.268s)
  hex dump (first 32 bytes):
    68 a1 d4 f0 00 02 20 00 01 00 00 00 00 00 00 00  h..... .........
    00 00 00 00 00 00 00 00 00 00 00 00 ff 7f 00 00  ................
  backtrace:
    [<c159b50c>] kmemleak_alloc+0x2c/0x60
    [<c1139c23>] __kmalloc+0x1c3/0x240
    [<c14e2627>] fib_default_rule_add+0x27/0x70
    [<c157f8df>] ip6mr_net_init+0x6f/0x140
    [<c14c4129>] ops_init+0x39/0x110
    [<c14c425f>] setup_net+0x5f/0xf0
    [<c14c46e4>] copy_net_ns+0x74/0xf0
    [<c105fc81>] create_new_namespaces+0xd1/0x160
    [<c105fedf>] unshare_nsproxy_namespaces+0x5f/0xa0
    [<c1038a94>] sys_unshare+0x114/0x280
    [<c15b7ecd>] sysenter_do_call+0x12/0x28
    [<ffffffff>] 0xffffffff


I've reproduced this on a recent net-next kernel (master as of this
Monday or so, git hash cef401de7be8c4e155c6746bfccf721a4fa5fab9),
using the script attached inline below.  The script is a trimmed down
version of something I have been using to stress test some l2tp_core
changes, but the ip6mr issue appears to exist on master as well as my
branch.  To get this to show up on my AMD64x2 I typically have to run
the script twice -- the first time around I get a bunch of modprobe
complaints from kmemleak, and the second time around I get ip6mr
complaints.

I'm not sure whether the trace above represents a false positive or
not -- any thoughts?

Thanks,
Tom

#!/bin/bash

BRIDGE=3Dbr0
BASE_IP=3D172.16.0.0
PREFIX=3D24
MAX_CHILDREN=3D300

log() { echo -e "[$(date)] $@"; }
err() { log "ERROR: $@" 1>&2; false; }
die() { err "$@"; exit 1; }
dbg() { test -n "$DEBUG" && log "$@" 1>&2; }

# $1 -- ip as a dotted quad
ip_to_decimal()
{
        local o1=3D${1%%.*}
        local o2=3D$(echo "$1" | cut -d. -f2)
        local o3=3D$(echo "$1" | cut -d. -f3)
        local o4=3D${1##*.}
        echo "($o1*(2^24)) + ($o2*(2^16)) + ($o3*(2^8)) + ($o4)" | bc
}

# $1 -- ip as a decimal number
decimal_to_ip()
{
        local h=3D$(printf "%08x" "$1")
        echo $(printf "%i" 0x${h:0:2}).$(printf "%i" 0x${h:2:2}).$(printf "=
%i" 0x${h:4:2}).$(printf "%i" 0x${h:6:2})
}

# $1 -- base
# $2 -- netmask
# $3 -- subnet index
offset_min_ipaddr()
{
        local nwoff=3D$(echo "$3 * (2^(32-$2))" | bc)
        local base=3D$(ip_to_decimal "$1")
        decimal_to_ip $((base+nwoff+1))
}

#$1 -- lower bound
#$2 -- upper bound
brand() {
        local r=3D$((RANDOM%$2))
        test $r -lt $1 && r=3D$(brand $1 $2)
        echo $r
}

# $1 -- network interface name
# $2 -- id
gen_script() {
        local laddr=3D$(offset_min_ipaddr $BASE_IP $PREFIX $2)
        local sleepfor=3D$(brand 0 5)

        dbg "$2 : $1 : sleepfor $sleepfor"

        cat << __EOF__
#!/bin/bash
ip addr add $laddr/255.255.0.0 dev $1 || exit 1
ip link set $1 up || exit 1
sleep $sleepfor
ip link set $1 down
__EOF__
}

# $1 -- netns
# $2 -- ve0
# $3 -- ve1
nsup() {
        local netns=3D"$1"
        local ve0=3D"$2"
        local ve1=3D"$3"
        local ret=3D1

        ip netns add $netns || return $ret

        ip link add name $ve0 type veth peer name $ve1 && \
                ip link set $ve1 netns $netns && \
                brctl addif $BRIDGE $ve0 && \
                ip link set $ve0 up && ret=3D0 || \
                ip netns delete $netns
                return $ret
}

# $1 -- netns
# $2 -- ve0
# $3 -- ve1
nsdown() {
        local netns=3D"$1"
        local ve0=3D"$2"
        local ve1=3D"$3"
        ip link set $ve0 down
        brctl delif $BRIDGE $ve0
        ip link del $ve0
        ip netns delete $netns
}

# $1 -- id
# $2 -- netns
do_netns() {
        local id=3D"$1"
        local netns=3D"$2"
        local runscript=3D/tmp/${netns}_run.sh
        local ve0=3D$(echo $netns | cut -d- -f1)-0
        local ve1=3D$(echo $netns | cut -d- -f1)-1

        dbg "$id : $netns"

        if nsup $netns $ve0 $ve1
        then
                gen_script $ve1 $id > $runscript && chmod +x $runscript && \
                        ip netns exec $netns $runscript || \
                        err "$id : $netns failed to gen/exec ns script"
                while ! nsdown $netns $ve0 $ve1 &> /dev/null; do sleep 1; d=
one
                rm $runscript
        else
                err "$id : $netns failed to come up"
        fi
}

waitforchildren() {
        local p=3D""
        log "Wait for $(echo "$cpids" | wc -w) child scripts to complete"
        dbg "cpids =3D $cpids"
        for p in $cpids; do wait $p; done
        cpids=3D""
}

#
# Entry point
#
trap waitforchildren EXIT

if ! brctl show | grep -q $BRIDGE
then
        brctl addbr $BRIDGE || die "Failed to create bridge $BRIDGE"
        ip link set $BRIDGE up || die "Failed to bring $BRIDGE up"
fi

c=3D0
cpids=3D""
while true
do
        nchildren=3D$(brand 1 $MAX_CHILDREN)
        echo clear > /sys/kernel/debug/kmemleak
        log "Spawn $nchildren network namespaces"
        for ((i=3D0;i<$nchildren;i++))
        do
                c=3D$((c+1))
                netns=3D$(uuidgen)
                ( cpids=3D""; do_netns $c $netns ) &
                cpids=3D"$cpids $!"
        done

        waitforchildren
        echo scan > /sys/kernel/debug/kmemleak
        if test $(wc -l /sys/kernel/debug/kmemleak | cut -d" " -f1) -gt 0
        then
                die "Kernel memory leak detected: see /sys/kernel/debug/kme=
mleak"
        fi
done


--=20
Tom Parkin
Katalix Systems Ltd
http://www.katalix.com
Catalysts for your Embedded Linux software development

--PNTmBPCT7hxwcZjr
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAEBAgAGBQJRCBovAAoJEJSMBmUKuovQLU8H/12K4jCj9U2vO4EoCD/v+EPN
+H4eVEcZusG57QlFGyFUGRptGpd+RJi5u3g88ZsEEopleDeri9JLmZOcHPfxCRZ/
jPmJrz2oUxVy3kcIkXu9tRPeLYACShLe1GB0sPzGfA5/O6P2cTHdwlryhZgbe5te
jfRiCv/NhflW25B3LZjPMtWQLpFNSMTbVO2sKY734lH1IbSJTUAj90Edyfk6kP/v
ENGxZnN9NTHqrM8Zlj+feLVPXF+ZaJtiuMYRdCyZRHr09APlbCkCMhhozPEuLLFl
cnKaLU3ohA4ePaVLzq6tJJIWMEASuWTXpzL/aI0ptpM7KZzMOngsIIG5+KfuH64=
=V2Ew
-----END PGP SIGNATURE-----

--PNTmBPCT7hxwcZjr--
