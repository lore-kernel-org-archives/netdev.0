From: Pete Zaitcev <zaitcev@redhat.com>
Subject: The boot time failure in tulip
Date: Mon, 1 Nov 2004 08:27:57 -0800
Message-ID: <20041101082757.64583eb2@lembas.zaitcev.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: jgarzik@redhat.com, zaitcev@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I have finally figured how the failure develops. I poked Jeff about it before,
but nothing could be done because it looked impossible to reproduce without
reboots. Just asking for negotiation with mii-tool would always yield a
working link. Also, this only happens with a dumb hub (tried several), but
works dandy when talking to a switch.

So, here's the deal. The Fedora startup has a segment which works like this:

           ip link set dev $1 up >/dev/null 2>&1
           timeout=0
           while [ $timeout -le 10 ]; do
                check_mii_tool $1
                m=$?
                check_ethtool $1
                e=$?
                if [ $m -eq 1 ] || [ $e -eq 1 ] ; then
                    return 1
                fi
                if [ $m -eq 2 ] && [ $e -eq 2 ] ; then
                    return 1
                fi
                usleep 500000
                timeout=$((timeout+1))
           done

It appears that the negotiation will not happen after "ip link set ... up"
if we keep beating the interface with mii-tool (despite the 0.5s delay).
Weird, huh?

It's enough to fix things if a 3s delay is inserted after the ip ... up.

I think the bug here is that polling with mii-tool disrupts the
autonegotiation. It is ok to return failure after a reset, but
eventually this has to resolve itself despite the polling.

I suspect that 3c59x has the same failure as well. But I haven't played
with it much.

-- Pete
