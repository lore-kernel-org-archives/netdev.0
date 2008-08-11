From: Mike Christie <michaelc-hcNo3dDEHLuVc3sceRu5cw@public.gmane.org>
Subject: Re: [RFC][PATCH 1/1] cxgb3i: cxgb3 iSCSI initiator
Date: Mon, 11 Aug 2008 11:50:32 -0500
Message-ID: <48A06DD8.80703@cs.wisc.edu>
References: <200807300019.m6U0JkdY012558@localhost.localdomain>	 <aday73jxdfs.fsf@cisco.com>	<200807311752.00911.divy@chelsio.com>	 <200808071145.03848.divy@chelsio.com>	 <489C8BEB.8060001@opengridcomputing.com>	<489CC58D.4010606@pobox.com>	 <adazlnlzc60.fsf@cisco.com> <20080810101935.5c8e8e9a@lxorguk.ukuu.org.uk>	 <489EE3DC.9060202@pobox.com> <1218380086.3418.21.camel@localhost.localdomain>
Reply-To: open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Jeff Garzik <jgarzik-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>, Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>, Roland Dreier <rdreier-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>, Steve Wise <swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, Divy Le Ray <divy-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>, Karen Xie <kxie-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org, daisyc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org, wenxiong-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org, bhua-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org, Dimitrios Michailidis <dm-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>, Casey Leedom <leedom-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>, linux-scsi <linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: James Bottomley <James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>
Return-path: <grbounce-FC1hwAUAAAA0O9VQcsxVj1UPjHD9r3x_=glio-open-iscsi=m.gmane.org-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
In-Reply-To: <1218380086.3418.21.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
List-Post: <mailto:open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <mailto:open-iscsi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <http://googlegroups.com/group/open-iscsi/subscribe>,
	<mailto:open-iscsi+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Id: netdev.vger.kernel.org


James Bottomley wrote:
> On Sun, 2008-08-10 at 08:49 -0400, Jeff Garzik wrote:
>> Alan Cox wrote:
>>>>  - It doesn't work in theory, because the suggestion (I guess) is that
>>>>    the iSCSI HBA has its own MAC and IP and behaves like a separate
>>> The iSCSI HBA is its own system - that is the root of the problem.
>> Indeed.
>>
>> Just like with TOE, from the net stack's point of view, an iSCSI HBA is 
>> essentially a wholly asynchronous remote system [with a really fast 
>> communication bus like PCI Express].
>>
>> As such, the task becomes updating the net stack such that 
>> formerly-private resources are now shared with an independent, external 
>> system...  with all the complexity, additional failure modes, and 
>> additional security complications that come along with that.
> 
> What's wrong with making it configurable identically to current software
> iSCSI?  i.e. plumb the thing into the current iscsi transport class so
> that we use the standard daemon for creating and binding sessions?
> Then, only once the session is bound do you let your iSCSI TOE stack
> take over.
> 
> That way the connection appears to the network as completely normal,
> because it has an open socket associated with it; and, since the
> transport class has done the connection login, it even looks like a
> normal iSCSI connection to the usual tools.  iSCSI would manage
> connection and authentication, so your TOE stack can be simply around
> the block acceleration piece (i.e. you'd need to get the iscsi daemon to
> do relogin and things).


This is what Chelsio and broadcom do today more or less. Chelsio did the 
socket trick you are proposing. Broadcom went with a different hack. But 
in the end both hook into the iscsi transport class (the current iscsi 
transport class works for this today), userspace daemon and tools, so 
that the iscsi daemon handles iscsi login, iscsi authentication and all 
other iscsi operations, like it does for software iscsi.


> 
> I would assume net will require some indicator that the opened
> connection has been subsumed, so it knows not to try to manage it, but
> other than that I don't see it will need any alteration.  The usual
> tools, like netfilter could even use this information to know the limits
> of their management.
> 
> If this model works, we can use it for TOE acceleration of individual
> applications (rather than the entire TCP stack) on an as needed basis.
> 
> This is like the port stealing proposal, but since the iSCSI daemon is
> responsible for maintaining the session, the port isn't completely
> stolen, just switched to accelerator mode when doing the iSCSI offload.
> 
