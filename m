From: Mike Rapoport <mike.rapoport@ravellosystems.com>
Subject: Re: [PATCH net-next 2/2] vxlan: allow specifying multiple default
 destinations
Date: Sun, 28 Apr 2013 01:57:12 +0300
Message-ID: <20130427225712.GA6772@zed>
References: <1366887829-3950-1-git-send-email-mike.rapoport@ravellosystems.com>
 <1366887829-3950-3-git-send-email-mike.rapoport@ravellosystems.com>
 <87txmtpyje.wl%atzm@stratosphere.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Atzm Watanabe <atzm@stratosphere.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys010aog108.obsmtp.com ([74.125.245.84]:50291 "HELO
	na3sys010aog108.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753499Ab3D0W5T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Apr 2013 18:57:19 -0400
Received: by mail-wi0-f198.google.com with SMTP id c10so2412295wiw.9
        for <netdev@vger.kernel.org>; Sat, 27 Apr 2013 15:57:17 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <87txmtpyje.wl%atzm@stratosphere.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 26, 2013 at 03:59:49PM +0900, Atzm Watanabe wrote:
> At Thu, 25 Apr 2013 14:03:49 +0300,
> Mike Rapoport wrote:
> > +/* Add remote to default destinations list */
> > +static int vxlan_remote_add(struct vxlan_dev *vxlan, struct nlattr *attr)
> > +{

...

> > +}
> 
> I think the default destinations should be used for not only sending
> but receiving, so when multicast address was added, it should be
> joined to the group, if the interface state is up.
> (Forbidding the change on the running interface may make it easy.)
> 
> Also vxlan_open() and vxlan_stop() will need to control the
> membership of groups in the default destination list.

My original idea was to simulate multicast group with a list of unicast
destinations for cases when multicast is impossible. I'd prefer to limit
the additional destinations for unicast addresses for now. The support
for several multicast groups with the same VNI can be added later on,
IMHO. 
 
> 
> >  /* See if multicast group is already in use by other ID */
> >  static bool vxlan_group_used(struct vxlan_net *vn,
> > @@ -1500,6 +1600,14 @@ static void vxlan_flush(struct vxlan_dev *vxlan)
> >  	spin_unlock_bh(&vxlan->hash_lock);
> >  }
> >  
> > +static void vxlan_remotes_flush(struct vxlan_dev *vxlan)
> > +{
> > +	struct vxlan_rdst *rd;
> > +
> > +	for (rd = vxlan->default_dst.remote_next; rd; rd = rd->remote_next)
> > +		vxlan_remote_destroy(vxlan, rd);
> > +}
> > +
> >  /* Cleanup timer and forwarding table on shutdown */
> >  static int vxlan_stop(struct net_device *dev)
> >  {
> > @@ -1511,6 +1619,7 @@ static int vxlan_stop(struct net_device *dev)
> >  	del_timer_sync(&vxlan->age_timer);
> >  
> >  	vxlan_flush(vxlan);
> > +	vxlan_remotes_flush(vxlan);
> >  
> >  	return 0;
> >  }
> 
> vxlan_stop() is called when interface state changes to down.
> I think the default destinations should not be flushed at this timing,
> and this should be done at dellink instead.

Agree, will fix.

> 
> Thanks.

--
Sincerely yours,
Mike.
