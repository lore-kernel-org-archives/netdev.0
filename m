From: "Anil Veerabhadrappa" <anilgv@broadcom.com>
Subject: Re: [PATCH] cnic: Fix ISCSI_KEVENT_IF_DOWN message handling.
Date: Wed, 29 Jul 2009 01:42:51 -0700
Message-ID: <1248856971.26650.221.camel@anilgv-desktop>
References: <C27F8246C663564A84BB7AB343977242178EE780E1@IRVEXCHCCR01.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "'Mike Christie'" <michaelc@cs.wisc.edu>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"James.Bottomley@HansenPartnership.com"
	<James.Bottomley@HansenPartnership.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>
To: "open-iscsi@googlegroups.com" <open-iscsi@googlegroups.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2342 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751449AbZG2InD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Jul 2009 04:43:03 -0400
In-Reply-To: <C27F8246C663564A84BB7AB343977242178EE780E1@IRVEXCHCCR01.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2009-07-29 at 00:55 -0700, Michael Chan wrote:
> Mike Christie wrote:
> 
> > Michael Chan wrote:
> > > When a net device goes down or when the bnx2i driver is unloaded,
> > > the code was not generating the ISCSI_KEVENT_IF_DOWN message
> > > properly and this could cause the userspace driver to crash.
> > >
> > > This is fixed by sending the message properly in the shutdown
> path.
> > > cnic_uio_stop() is also added to send the message when bnx2i is
> > > unregistering.
> > >
> > > Signed-off-by: Michael Chan <mchan@broadcom.com>
> > > ---
> > >  drivers/net/cnic.c |   23 +++++++++++++++++++++--
> > >  1 files changed, 21 insertions(+), 2 deletions(-)
> > >
> > > diff --git a/drivers/net/cnic.c b/drivers/net/cnic.c
> > > index 4d1515f..4869d77 100644
> > > --- a/drivers/net/cnic.c
> > > +++ b/drivers/net/cnic.c
> > > @@ -227,7 +227,7 @@ static int cnic_send_nlmsg(struct
> > cnic_local *cp, u32 type,
> > >     }
> > >
> > >     rcu_read_lock();
> > > -   ulp_ops = rcu_dereference(cp->ulp_ops[CNIC_ULP_ISCSI]);
> > > +   ulp_ops = rcu_dereference(cnic_ulp_tbl[CNIC_ULP_ISCSI]);
> > >     if (ulp_ops)
> > >             ulp_ops->iscsi_nl_send_msg(cp->dev, msg_type, buf,
> len);
> > >     rcu_read_unlock();
> > > @@ -319,6 +319,20 @@ static int cnic_abort_prep(struct
> > cnic_sock *csk)
> > >     return 0;
> > >  }
> > >
> > > +static void cnic_uio_stop(void)
> > > +{
> > > +   struct cnic_dev *dev;
> > > +
> > > +   read_lock(&cnic_dev_lock);
> > > +   list_for_each_entry(dev, &cnic_dev_list, list) {
> > > +           struct cnic_local *cp = dev->cnic_priv;
> > > +
> > > +           if (cp->cnic_uinfo)
> > > +                   cnic_send_nlmsg(cp, ISCSI_KEVENT_IF_DOWN,
> NULL);
> >
> > I don't think you can call this with the cnic_dev_lock held.
> > They have
> > the same sleeping restrictions as a spin_lock right? If so,
> > the problem
> > is that iscsi_nl_send_ms calls iscsi_offload_mesg which uses
> GFP_NOIO
> > and can sleep.
> >
> >
> In that case, can I send in a patch to change iscsi_offload_mesg() to
> use GFP_ATOMIC?
> 
After this change, if iscsi_transport is unable to push the message to
user daemon because of memory issues, will the original issue of uio
crash re-appear?

Original issue: A did not notify B
Fix : A calls C to send message to B
      if C cannot deliver message to B, original problem stays???


> 
> --~--~---------~--~----~------------~-------~--~----~
> You received this message because you are subscribed to the Google Groups "open-iscsi" group.
> To post to this group, send email to open-iscsi@googlegroups.com
> To unsubscribe from this group, send email to open-iscsi+unsubscribe@googlegroups.com
> For more options, visit this group at http://groups.google.com/group/open-iscsi
> -~----------~----~----~----~------~----~------~--~---
> 
> 


