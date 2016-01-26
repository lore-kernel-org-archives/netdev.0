From: Jarod Wilson <jarod@redhat.com>
Subject: Re: [RFC PATCH net] net/core: don't increment rx_dropped on inactive
 slaves
Date: Mon, 25 Jan 2016 23:45:25 -0500
Message-ID: <20160126044525.GK59058@redhat.com>
References: <1453489882-57948-1-git-send-email-jarod@redhat.com>
 <20160124.224222.1748787418887617295.davem@davemloft.net>
 <20160125142720.GD59058@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, edumazet@google.com,
	jiri@mellanox.com, daniel@iogearbox.net, tom@herbertland.com,
	j.vosburgh@gmail.com, vfalico@gmail.com, gospo@cumulusnetworks.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160125142720.GD59058@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jan 25, 2016 at 09:27:20AM -0500, Jarod Wilson wrote:
> On Sun, Jan 24, 2016 at 10:42:22PM -0800, David Miller wrote:
> > From: Jarod Wilson <jarod@redhat.com>
> > Date: Fri, 22 Jan 2016 14:11:22 -0500
> > 
> > > diff --git a/net/core/dev.c b/net/core/dev.c
> > > index 8cba3d8..1354c7b 100644
> > > --- a/net/core/dev.c
> > > +++ b/net/core/dev.c
> > > @@ -4153,8 +4153,11 @@ ncls:
> > >  		else
> > >  			ret = pt_prev->func(skb, skb->dev, pt_prev, orig_dev);
> > >  	} else {
> > > +		if (deliver_exact)
> > > +			goto inactive; /* bond or team inactive slave */
> > >  drop:
> > >  		atomic_long_inc(&skb->dev->rx_dropped);
> > > +inactive:
> > >  		kfree_skb(skb);
> > >  		/* Jamal, now you will not able to escape explaining
> > >  		 * me how you were going to use this. :-)
> > 
> > I agree that rx_dropped is not the correct stat to bump here, but
> > I'm totally against the event disappearing completely into thin
> > air.
> > 
> > You have to replace the rx_dropped bump with _something_.
> > 
> > The only reason this hasn't been "fixed" yet is that everyone is
> > too damn lazy to implement that "something".
> 
> Would you want to see all things that shouldn't increment rx_dropped come
> in one shot, along with the four or so other counters, as discussed in the
> prior thread, or can they be done piecemeal? To date, I'm really only
> familiar with this particular case, and could probably get something
> together this week. To address the rest, I'd have to poke around a bit
> more and see what there is to see and do.

Spent a while hacking around today, now have this, p7p1 and p5p2 are
the inactive slaves in the bond:

[root@dell-per720-06 ~]# cat /proc/net/dev
Inter-|   Receive                                                       |  Transmit
 face |bytes    packets errs drop drop_i fifo frame compressed multicast|bytes    packets errs drop fifo colls carrier compressed
  p6p1:   16024     238    0    0      0    0     0          0       521        0       0    0    0    0     0       0          0
  p7p1: 1691386   16537    0    0  16568    0     0          0       488        0       0    0    0    0     0       0          0
  p7p2: 1709438   16718    0    0      0    0     0          0       561        0       0    0    0    0     0       0          0
 bond0: 6183056   63065    0    0  33151    0     0          0     13964    24747     193    0    0    0     0       0          0
  p4p1:       0       0    0    0      0    0     0          0         0        0       0    0    0    0     0       0          0
  p4p2:       0       0    0    0      0    0     0          0         0        0       0    0    0    0     0       0          0
    lo:    4928      50    0    0      0    0     0          0         0     4928      50    0    0    0     0       0          0
  p5p1: 2259498   23401    0    0      0    0     0          0      6740    24747     193    0    0    0     0       0          0
  p5p2: 2232172   23127    0    0  16583    0     0          0      6736        0       0    0    0    0     0       0          0
   em4: 2347251   18224    0    0      0    0     0          0        90     4541      47    0    0    0     0       0          0
   em2: 1590296   16061    0    0      0    0     0          0        81        0       0    0    0    0     0       0          0
   em1: 1590180   16060    0    0      0    0     0          0        79        0       0    0    0    0     0       0          0
   em3: 2343156   18209    0    0      0    0     0          0        94        0       0    0    0    0     0       0          0
[root@dell-per720-06 ~]# cat /sys/devices/virtual/net/bond0/statistics/rx_dropped_inactive
33181

Haven't yet thrown together anything for ethtool -S output as Eric had
suggested, but I'll dig into that tomorrow.

-- 
Jarod Wilson
jarod@redhat.com
