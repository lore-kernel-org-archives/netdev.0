From: Jon Maxwell <jmaxwell@redhat.com>
Subject: Re: [PATCH net] bridge: notify user space of fdb port change
Date: Fri, 23 May 2014 00:59:32 -0400 (EDT)
Message-ID: <1679971005.11740655.1400821172875.JavaMail.zimbra@redhat.com>
References: <1399967708-7283-1-git-send-email-jmaxwell@redhat.com> <5372BA1E.8000402@lab.ntt.co.jp> <2052318198.6465872.1400101664337.JavaMail.zimbra@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Jon Maxwell <jmaxwell37@gmail.com>, stephen@networkplumber.org,
	davem@davemloft.net, vyasevic@redhat.com,
	bridge@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, jpirko@redhat.com
To: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <2052318198.6465872.1400101664337.JavaMail.zimbra@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



> ----- Original Message -----
> > From: "Toshiaki Makita" <makita.toshiaki@lab.ntt.co.jp>
> > To: "Jon Maxwell" <jmaxwell37@gmail.com>, stephen@networkplumber.org
> > Cc: davem@davemloft.net, vyasevic@redhat.com,
> > bridge@lists.linux-foundation.org, netdev@vger.kernel.org,
> > linux-kernel@vger.kernel.org, jpirko@redhat.com, jmaxwell@redhat.com
> > Sent: Wednesday, May 14, 2014 10:34:38 AM
> > Subject: Re: [PATCH net] bridge: notify user space of fdb port change
> > 
> > (2014/05/13 16:55), Jon Maxwell wrote:
> > > From: Jon Maxwell <jmaxwell37@gmail.com>
> > > 
> > > There has been a number incidents recently where customers running KVM
> > > have
> > > reported that VM hosts on different Hypervisors are unreachable. Based on
> > > pcap traces we found that the bridge was broadcasting the ARP request out
> > > onto the network. However some NICs have an inbuilt switch which on
> > > occasions
> > > were broadcasting the VMs ARP request back through the physical NIC on
> > > the
> > > Hypervisor. This resulted in the bridge changing ports and incorrectly
> > > learning
> > > that the VMs mac address was external. As a result the ARP reply was
> > > directed
> > > back onto the external network and VM never updated it's ARP cache. This
> > > patch
> > > will notify the bridge command to identify such port toggling.
> > > 
> > > Signed-off-by: Jon Maxwell <jmaxwell37@gmail.com>
> > > ---
> > >  net/bridge/br_fdb.c | 2 ++
> > >  1 file changed, 2 insertions(+)
> > > 
> > > diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
> > > index 9203d5a..37742e2 100644
> > > --- a/net/bridge/br_fdb.c
> > > +++ b/net/bridge/br_fdb.c
> > > @@ -507,6 +507,8 @@ void br_fdb_update(struct net_bridge *br, struct
> > > net_bridge_port *source,
> > >  					source->dev->name);
> > >  		} else {
> > >  			/* fastpath: update of existing entry */
> > > +			if (source->port_no != fdb->dst->port_no)
> > 
> > It seems that we don't need to fetch port_no and it is enough to compare
> > source and fdb->dst.
> 
> It may save a few instructions but I have not tested it.
> 
> > 
> > > +				fdb_notify(br, fdb, RTM_NEWNEIGH);
> > >  			fdb->dst = source;
> > >  			fdb->updated = jiffies;
> > >  			if (unlikely(added_by_user))
> > > 
> > 
> > This notifies fdb entry before updating existing entry. Is this on purpose?
> > I think we should notify the updated fdb entry.
> > Similar code fdb_add_entry() does after updating it.
> 
> It was not on purpose but for this particular case there will be burst of
> notifies
> so it probably does not matter. However I agree it should be after the
> update.
> I will do that along with adding the unlikely() conditional and resubmit.
> 
> > 
> > Also, isn't it better to move update of dst into "if" block?
> 
> I would prefer to leave this portion as alone and only use the if
> statement for the notify.
> 
> > 
> > 	if (source != fdb->dst) {
> > 		fdb->dst = source;
> > 		modified = true;
> > 	}
> > 	...
> > 	if (modified) ...
> > 

Makita-san,

I recoded this using your idea and ran it through a reproducer.
It work fine. After some more consideration I agree that 
setting fdb->dst = source is only required when source != fdb->dst.

Thanks for your suggestions. This is the revised patch. It should 
retain the original behaviour except for the notify after the fdb update.  

Please let me know if you have any further input?

$ diff -Naur br_fdb.c br_fdb.c.patch
--- br_fdb.c        2014-05-17 12:43:23.346319609 +1000
+++ br_fdb.c.patch        2014-05-17 16:54:46.280235728 +1000
@@ -487,6 +487,7 @@
 {
         struct hlist_head *head = &br->hash[br_mac_hash(addr, vid)];
         struct net_bridge_fdb_entry *fdb;
+        bool fdb_modified = 0;
 
         /* some users want to always flood. */
         if (hold_time(br) == 0)
@@ -507,10 +508,16 @@
                                         source->dev->name);
                 } else {
                         /* fastpath: update of existing entry */
-                        fdb->dst = source;
+                        if (unlikely(source != fdb->dst))
+                                {
+                                fdb->dst = source;
+                                fdb_modified = 1;
+                                }
                         fdb->updated = jiffies;
                         if (unlikely(added_by_user))
                                 fdb->added_by_user = 1;
+                        if (unlikely(fdb_modified))
+                                fdb_notify(br, fdb, RTM_NEWNEIGH);
                 }
         } else {
                 spin_lock(&br->hash_lock);


> > Thanks,
> > Toshiaki Makita
> > 
> 
