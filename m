From: mgross <markgross@thegnar.org>
Subject: Re: [patch] pm_qos update fixing mmotm 2010-05-11 -dies in
 pm_qos_update_request()
Date: Sun, 16 May 2010 17:12:41 -0700
Message-ID: <20100517001241.GA2962@thegnar.org>
References: <20100515021922.GA5041@thegnar.org>
 <201005152138.47178.rjw@sisk.pl>
 <20100515214256.GA3506@thegnar.org>
 <201005170021.25427.rjw@sisk.pl>
Reply-To: markgross@thegnar.org
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: markgross@thegnar.org, Valdis.Kletnieks@vt.eu,
	mgross@linux.intel.com, akpm@linux-foundation.org,
	davem@davemloft.net, linux-kernel@vger.kernel.org,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-pm@lists.linux-foundation.org
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <201005170021.25427.rjw@sisk.pl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, May 17, 2010 at 12:21:25AM +0200, Rafael J. Wysocki wrote:
> On Saturday 15 May 2010, mgross wrote:
> > On Sat, May 15, 2010 at 09:38:47PM +0200, Rafael J. Wysocki wrote:
> > > On Saturday 15 May 2010, mgross wrote:
> > > > I apologize for the goofy email address.  
> > > > 
> > > > The following is a fix for the crash reported by Valdis.
> > > > 
> > > > The problem was that the original pm_qos silently fails when a request
> > > > update is passed to a parameter that has not been added to the list
> > > > yet.  It seems that the e1000e is doing this.  This update restores this
> > > > behavior.
> > > > 
> > > > I need to think about how to better handle such abuse, but for now this
> > > > restores the original behavior.
> > > 
> > > Can you please post a signed-off incremental patch against
> > > 
> > > git://git.kernel.org/pub/scm/linux/kernel/git/rafael/suspend-2.6.git for-llinus
> > > 
> > > that contains your original PM QOS update?
> > 
> > No problem:
> >
> > Signed-off-by: markgross <markgross@thegnar.org>
> 
> Thanks!  Do you want to use this address for the sign-off or the Intel one?

I guess so.  Ever since switching groups within intel last summer my
mgross@linux.intel.com address isn't checked as often as this one. 

The other option is to use my outlook email (mark.gross@intel.com), but
I really hate posting from outlook.  Besides, doing upstream kernel
stuff isn't my day job any more so using markgross@thegnar.org  makes
sense to me.

thanks,

--mgross



> 
> Rafael
> 
>  
> > From 487b8dcaeb66d3c226d4c06c1bd99689f93024be Mon Sep 17 00:00:00 2001
> > From: mgross <mgross@mgross-desktop.(none)>
> > Date: Sat, 15 May 2010 14:30:15 -0700
> > Subject: [PATCH] Gard against pm_qos users calling API before registering a proper
> >  request.
> > 
> > This update handles a use case where pm_qos update requests need to
> > silently fail if the update is being sent to a handle that is null.
> > 
> > The problem was that the original pm_qos silently fails when a request
> > update is passed to a parameter that has not been added to the list yet.
> > This update restores that behavior.
> > 
> > Signed-off-by: markgross <markgross@thegnar.org>
> > 
> > ---
> >  kernel/pm_qos_params.c |   26 ++++++++++++++------------
> >  1 files changed, 14 insertions(+), 12 deletions(-)
> > 
> > diff --git a/kernel/pm_qos_params.c b/kernel/pm_qos_params.c
> > index a1aea04..f42d3f7 100644
> > --- a/kernel/pm_qos_params.c
> > +++ b/kernel/pm_qos_params.c
> > @@ -252,19 +252,21 @@ void pm_qos_update_request(struct pm_qos_request_list *pm_qos_req,
> >  	int pending_update = 0;
> >  	s32 temp;
> >  
> > -	spin_lock_irqsave(&pm_qos_lock, flags);
> > -	if (new_value == PM_QOS_DEFAULT_VALUE)
> > -		temp = pm_qos_array[pm_qos_req->pm_qos_class]->default_value;
> > -	else
> > -		temp = new_value;
> > -
> > -	if (temp != pm_qos_req->value) {
> > -		pending_update = 1;
> > -		pm_qos_req->value = temp;
> > +	if (pm_qos_req) { /*guard against callers passing in null */
> > +		spin_lock_irqsave(&pm_qos_lock, flags);
> > +		if (new_value == PM_QOS_DEFAULT_VALUE)
> > +			temp = pm_qos_array[pm_qos_req->pm_qos_class]->default_value;
> > +		else
> > +			temp = new_value;
> > +
> > +		if (temp != pm_qos_req->value) {
> > +			pending_update = 1;
> > +			pm_qos_req->value = temp;
> > +		}
> > +		spin_unlock_irqrestore(&pm_qos_lock, flags);
> > +		if (pending_update)
> > +			update_target(pm_qos_req->pm_qos_class);
> >  	}
> > -	spin_unlock_irqrestore(&pm_qos_lock, flags);
> > -	if (pending_update)
> > -		update_target(pm_qos_req->pm_qos_class);
> >  }
> >  EXPORT_SYMBOL_GPL(pm_qos_update_request);
> >  
> > 
> 
