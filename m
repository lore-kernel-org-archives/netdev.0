From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: Re: [PATCH] selftests: add a generic testsuite for ethernet device
Date: Mon, 3 Apr 2017 15:15:26 +0200
Message-ID: <20170403131526.GC30824@Red>
References: <20170331125752.20074-1-clabbe.montjoie@gmail.com>
 <20170331125752.20074-2-clabbe.montjoie@gmail.com>
 <20170331141241.GH22609@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, shuah@kernel.org,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        linux-kselftest@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170331141241.GH22609@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Mar 31, 2017 at 04:12:41PM +0200, Andrew Lunn wrote:
> On Fri, Mar 31, 2017 at 02:57:52PM +0200, Corentin Labbe wrote:
> > This patch add a generic testsuite for testing ethernet network device driver.
> > 
> > Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
> > ---
> >  tools/testing/selftests/net/Makefile     |   2 +-
> >  tools/testing/selftests/net/netdevice.sh | 185 +++++++++++++++++++++++++++++++
> >  2 files changed, 186 insertions(+), 1 deletion(-)
> >  create mode 100755 tools/testing/selftests/net/netdevice.sh
> > 
> > diff --git a/tools/testing/selftests/net/Makefile b/tools/testing/selftests/net/Makefile
> > index fbfe5d0..35cbb4c 100644
> > --- a/tools/testing/selftests/net/Makefile
> > +++ b/tools/testing/selftests/net/Makefile
> > @@ -5,7 +5,7 @@ CFLAGS += -I../../../../usr/include/
> >  
> >  reuseport_bpf_numa: LDFLAGS += -lnuma
> >  
> > -TEST_PROGS := run_netsocktests run_afpackettests test_bpf.sh
> > +TEST_PROGS := run_netsocktests run_afpackettests test_bpf.sh netdevice.sh
> >  TEST_GEN_FILES =  socket
> >  TEST_GEN_FILES += psock_fanout psock_tpacket
> >  TEST_GEN_FILES += reuseport_bpf reuseport_bpf_cpu reuseport_bpf_numa
> > diff --git a/tools/testing/selftests/net/netdevice.sh b/tools/testing/selftests/net/netdevice.sh
> > new file mode 100755
> > index 0000000..89ba827
> > --- /dev/null
> > +++ b/tools/testing/selftests/net/netdevice.sh
> > @@ -0,0 +1,185 @@
> > +#!/bin/sh
> > +#
> > +# This test is for checking network interface
> > +# For the moment it tests only ethernet interface (but wifi could be easily added)
> > +#
> > +# We assume that all network driver are loaded
> > +# if not they probably have failed earlier in the boot process and their logged error will be catched by another test
> > +#
> > +
> 
> Hi Corentin
> 
> Nice to see some basic tests.
> 
> > +# this function will try to up the interface
> > +# if already up, nothing done
> > +# arg1: network interface name
> > +kci_net_start()
> > +{
> > +	netdev=$1
> > +
> > +	ip link show "$netdev" |grep -q UP
> > +	if [ $? -eq 0 ];then
> > +		echo "SKIP: interface $netdev already up"
> > +		return 0
> > +	fi
> > +
> > +	ip link set "$netdev" up
> > +	if [ $? -ne 0 ];then
> > +		echo "FAIL: Fail to up $netdev"
> > +		return 1
> > +	else
> > +		echo "PASS: set interface $netdev up"
> > +		NETDEV_STARTED=1
> > +	fi
> 
> This is going to be problematic.
> 
> 3: eth1: <BROADCAST,MULTICAST> mtu 1500 qdisc pfifo_fast state DOWN mode DEFAULT group default qlen 1000
>     link/ether 8e:01:30:d5:63:ff brd ff:ff:ff:ff:ff:ff
> 4: lan1@eth1: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode DEFAULT group default qlen 1000
>     link/ether 8e:01:30:d5:63:ff brd ff:ff:ff:ff:ff:ff
> 
> lan1 has eth1 as its master interface. If you try to up lan1 while eth1 is down:
> 
> # ip link set lan1 up
> RTNETLINK answers: Network is down
> 
> > +
> > +ls /sys/class/net/ |grep -vE '^lo|^tun' | grep -E '^eth|enp[0-9]s[0-9]' > "$TMP_LIST_NETDEV"
> > +while read netdev
> > +do
> > +	kci_test_netdev "$netdev"
> > +done < "$TMP_LIST_NETDEV"
> 
> Because of the grep, on this board, you won't actually test
> lan1. Which is a shame. It would be nice to test it, and the other
> interfaces like it.
> 
> Rather than going on the order ls gives you, could you order it based
> on the ifnum? The master has to exist before a slave can be
> created. Hence the master has a lower ifnum than the slave. So bring
> the interfaces up in ifnum order, and down in reverse order.
> 
> Thanks
> 	Andrew

By ifnum, you mean by the order that "ip link" gives ?

Regards
