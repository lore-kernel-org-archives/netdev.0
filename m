From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] PKT_SCHED: Provide compat policer stats
	in	action	policer
Date: 22 Dec 2004 08:10:13 -0500
Message-ID: <1103721013.1090.30.camel@jzny.localdomain>
References: <20041215130128.GK8493@postel.suug.ch>
	 <1103119774.1077.74.camel@jzny.localdomain> <41C05B60.6030504@trash.net>
	 <1103484249.1046.143.camel@jzny.localdomain> <41C6A6CC.1050105@trash.net>
	 <1103552830.1049.355.camel@jzny.localdomain>
	 <20041221001621.GY17998@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>, "David S. Miller" <davem@davemloft.net>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20041221001621.GY17998@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



Dont have time to look at it right now - If you can also have it
generate traffic in that framework and validate results that would
be similar to what i have.

cheers,
jamal

On Mon, 2004-12-20 at 19:16, Thomas Graf wrote:
> * jamal <1103552830.1049.355.camel@jzny.localdomain> 2004-12-20 09:27
> > I just stared quickly at what Thomas has and realize its not really
> > automated. In my case it is easier because i can click on the proverbial
> > one-button and run 20 tests (including a subset of the policer ones)
> > and even capturing tcpdumps. I have attached a sample testcase. 
> 
> I've put up a snapshot of what I have at:
> http://people.suug.ch/~tgr/tmp/tc-testsuite.tar.gz
> 
> .. and a special for jamal not including iproute2 sources
> so you can save a few bucks ;->
> http://people.suug.ch/~tgr/tmp/tc-testsuite-jamal.tar.bz2
> 
> I'm not sure what you mean, it's all automated and actually
> quite similar to what you've included. Actually, we could
> simply run your testscript under my testsuite if you
> replace the "tc" with a variable given to the script.
> 
> My indev test: (requires a patched iproute2 to correctly
> print [ indev INDEV ] in usage text, patches follow later)
> 
> ----
> #!/bin/bash
> # vim: ft=sh
> #
> source lib/generic.sh
> 
> TYPE=$1; shift
> FILTER=$@
> 
> HELP=`$TC filter add ${TYPE} help 2>&1`
> 
> if [ "`echo $HELP | grep \"indev DEV\"`" ]; then
>         if [ $CONFIG_NET_CLS_IND ]; then
>                 ts_tc "attr-indev" "filter addition" $FILTER indev "eth1"
>         else
>                 ts_log "attr-indev: No INDEV support, checking error return value"
>                 RES=`$TC $FILTER indev "eth1" 2>&1`
>                 if [ "`echo $RES | head -1`" != \
>                      "RTNETLINK answers: Operation not supported" ]; then
>                         echo "Warning: Kernel did not report EOPNOTSUPP"
>                 fi
>         fi
> else
>         # no support for indev, add filter anyway to not break deletion
>         ts_log "ip version doesn't support indev, skipping"
>         ts_tc "attr-indev" "dummy addition" $FILTER
> fi
> ---
> 
> Here's an example run:
> 
> tgr:axs ~/dev/tc-testsuite make alltests
> Running cls-testbed.t [iproute2-2.4.7/2.6.10-rc3-bk12]: FAILED
> Running cls-testbed.t [iproute2-2.6.9/2.6.10-rc3-bk12]: PASS
> Running dsmark.t [iproute2-2.4.7/2.6.10-rc3-bk12]: FAILED
> Running dsmark.t [iproute2-2.6.9/2.6.10-rc3-bk12]: PASS
> Running std-cbq.t [iproute2-2.4.7/2.6.10-rc3-bk12]: PASS
> Running std-cbq.t [iproute2-2.6.9/2.6.10-rc3-bk12]: PASS
> tgr:axs ~/dev/tc-testsuite 
> 
> So, 2 of them failed, let's see what happenend:
> tgr:axs ~/dev/tc-testsuite cat results/cls-testbed.t.iproute2-2.4.7.out
> ...
> Preparing classifier testbed with qdisc dsmark
> cls-testbed: dsmark root qdisc creation failed:
> command: iproute2/iproute2-2.4.7/tc/tc qdisc add dev lo root handle 10:0 dsmark indices 64 default_index 1 set_tc_index
> stderr output:
> Unknown qdisc "dsmark", hence option "indices" is unparsable
> ...
> 
> I'll take a closer look at tcng to see how we can put the best parts of both together.
> It will definitely be no problem to integrate your expect based tests.
> 
