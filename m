From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH] PKT_SCHED: Initialize list field in dummy qdiscs
Date: Sat, 6 Nov 2004 02:18:43 +0100
Message-ID: <20041106011843.GI12289@postel.suug.ch>
References: <418B4C7C.8000402@crocom.com.pl> <20041105115430.GP19714@rei.reeler.org> <418B4C7C.8000402@crocom.com.pl> <20041105141640.GQ19714@rei.reeler.org> <418BA66A.60804@trash.net> <20041105163951.GY12289@postel.suug.ch> <418BB7D2.6060908@trash.net> <20041105175812.GZ12289@postel.suug.ch> <418BC40E.8080402@trash.net> <20041105194303.GA12289@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@oss.sgi.com, spam@crocom.com.pl,
        kuznet@ms2.inr.ac.ru, jmorris@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <20041105194303.GA12289@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Thomas Graf <20041105194303.GA12289@postel.suug.ch> 2004-11-05 20:43
> * Patrick McHardy <418BC40E.8080402@trash.net> 2004-11-05 19:18
> > Yes, but there doesn't seem to be a path where this is true.
> 
> I will double check this, there must be something wrong with
> one of the callers to qdisc_destroy since it's the only way
> entries can be removed from qdisc_list and otherwise the oops wouldn't
> show up with the POISON1.

I think I've found the problem and it sounds to banal to be true.
qdisc_destroy uses list_del when it used to use a manual list
management which would not interfer any list walkers. the list
walkers are not protected on UP systems, that's why it was
impossible to trigger it for me with SMP enabled. So a qdisc_list
walker such as qdisc_lookup could have its next pointer overwritten
with LIST_POISON1 while walking if qdisc_destroy is called in between?
It sounds so right but on the other hand all the callers except
dev_shutdown should be serialized with any of the list walkers by the
rtnl sempaphore.

I guess I'm missing that little bit of experience but it would
help to use _rcu list variantes, would it?
