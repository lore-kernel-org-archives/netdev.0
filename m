From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH V3] netxen: fix ethtool rx_dropped information in ethtool
 get_ethtool_stats()
Date: Sat, 19 Jul 2014 18:28:16 +0200
Message-ID: <20140719162816.GB7590@electric-eye.fr.zoreil.com>
References: <1405655009-18975-1-git-send-email-ethan.zhao@oracle.com>
 <C562D0E12CBDE44E8A0CCAB77060096701283AD344@AVMB1.qlogic.org>
 <049BCC6F-0A2E-421A-9873-0B7ED6FFB3AC@gmail.com>
 <20140719101946.GA4319@electric-eye.fr.zoreil.com>
 <CABawtvP4+B_smOyi-=vt56KuUthzHF9L059PXP4ekXA7KPk_Dw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rajesh Borundia <rajesh.borundia@qlogic.com>,
	Ethan Zhao <ethan.zhao@oracle.com>,
	Manish Chopra <manish.chopra@qlogic.com>,
	Sony Chacko <sony.chacko@qlogic.com>,
	netdev <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>
To: Ethan Zhao <ethan.kernel@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CABawtvP4+B_smOyi-=vt56KuUthzHF9L059PXP4ekXA7KPk_Dw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ethan Zhao <ethan.kernel@gmail.com> :
> On Sat, Jul 19, 2014 at 6:19 PM, Francois Romieu <romieu@fr.zoreil.com> wrote:
> > Ethan Zhao <ethan.kernel@gmail.com> :
[...]
> > I'd rather see ethtool stats provides one of those:
> > 1. hardware stats only
>   Sounds very clear, is it done clear, if so we need other tools ?
> Then why net core increase dev->dropped like
> 
> atomic_long_inc(&skb->dev->rx_dropped);
> 
> and mess some of the info to dev. just let ifconfig report it without detail ?

(side note: ifconfig is a bit 90ish)

Regarding the "without details" part, I don't expect ifconfig to tell users
that packets are dropped at net/core/dev.c:3279 because of empty softnet_data
queue in enqueue_to_backlog. More to the point below.

[...]
> > 2. needs works. 1. hurts any requirement where it would priviously had
> > been so easy to add a few lines of code in the driver and push the mess
> > straight from kernel to the end user application.
> 
>   Maybe some guys think that is enough to mess them together while not
> identify the information from net core or driver. that is better than
> lose info /no info.

Probably.

>  My case is user could be confused when run 'ifconfig' and 'ethtool'
> to this netxen device. ifconfig reports packets dropped. but ethtool
> says zero. does that mean it is not issue of driver forever ? 

s/driver/hardware/

Hardware correctly delivers packets if ethtool says zero [*]

"correctly" must be understood in the context of said hardware abilities.

[*] Of course we don't live in a world of unicorns and it's almost
    unavoidable to check drivers's code to figure which stats are _really_
    hardware only in ethtool output.

A part of ethtool if close to bare metal abilities - including protocol
offloading related ones - whereas ifconfig provides a software oriented
vision of layer 2 operations.

<digressio>
People at QLogic have not included *any* hardware counter in their
netxen ethtool stats code. Nada, keud. It's a bit deceptive for a gigabit
ethernet card and http://www.qlogic.com/Search/Pages/Search.aspx?k=NX2031
gives no hint.
</digressio>

I won't claim it's intuitive. However:

$ LANG=C man ifconfig
[...]
NOTE
       This  program  is obsolete!  For replacement check ip addr and ip link.
       For statistics use ip -s link.

$ LANG=C man ip
[...]
     -f, -family <FAMILY>
              Specifies the protocol family to use. The protocol family iden-
              tifier can be one of inet, inet6, bridge, ipx, dnet or link.  If
              this option is not present, the protocol family is guessed from
              other arguments.  If the rest of the command line does not give
              enough information to guess the family, ip falls back to the
              default one, usually inet or any.  link is a special family
                                                 ^^^^^^^^^^^^^^^^^^^^^^^^
              identifier meaning that no networking protocol is involved.
              ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

(huh, "special"...)

$ LANG=C man ethtool
[...]
      -S --statistics
              Queries the specified network device for NIC- and driver-specif-
              ic statistics.

Some code stands between drivers and the upper part of the topmost
no-networking-procol layer, whence the differing stats: they are not
the same thing. Users can understand it.

> who could tell where the packets are dropped, and for what ?

One can't always answer beyond some coarse implementation level. There is
no such thing as a kernel MIB for the net core internal details.

Would you disagree that some of those - rx_dropped locations for instance -
are better kept in the scope of debug and trace utilities ?

> So I would like the name of the data fields that ethtool output is be
> better defined. Instead of saying is not covered by ethtool.

I respectfully disagree.

ethtool and ip are two different tools.

Regarding netxen driver, I do not want more ip / ifconfig stats in
ethtool code. It's quite the opposite: netxen ethtool code has no
business duplicating those and it should instead focus on real hardware
stats. 

-- 
Ueimor
