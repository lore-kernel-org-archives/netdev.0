From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [RFC PATCH v2 2/2] selinux: Support for the new TUN LSM hooks
Date: Wed, 12 Aug 2009 18:07:49 -0500
Message-ID: <20090812230749.GA11633@us.ibm.com>
References: <20090810172238.7946.34247.stgit@flek.lan> <20090810172850.7946.25175.stgit@flek.lan> <20090812221440.GA8524@us.ibm.com> <200908121855.24061.paul.moore@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-security-module@vger.kernel.org, netdev@vger.kernel.org,
	selinux@tycho.nsa.gov
To: Paul Moore <paul.moore@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e38.co.us.ibm.com ([32.97.110.159]:46421 "EHLO
	e38.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751736AbZHLXHt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Aug 2009 19:07:49 -0400
Content-Disposition: inline
In-Reply-To: <200908121855.24061.paul.moore@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Quoting Paul Moore (paul.moore@hp.com):
> On Wednesday 12 August 2009 06:14:40 pm Serge E. Hallyn wrote:
> > Quoting Paul Moore (paul.moore@hp.com):
> > > +static int selinux_tun_dev_attach(struct sock *sk)
> > > +{
> > > +	struct sk_security_struct *sksec = sk->sk_security;
> > > +	u32 sid = current_sid();
> > > +	int err;
> > > +
> > > +	err = avc_has_perm(sid, sksec->sid, SECCLASS_TUN_SOCKET,
> > > +			   TUN_SOCKET__RELABELFROM, NULL);
> > > +	if (err)
> > > +		return err;
> > > +	err = avc_has_perm(sid, sid, SECCLASS_RAWIP_SOCKET,
> >
> > Was RAWIP on purpose here?
> 
> Nope, a mistake on my part that I hadn't caught yet.  Thanks.
> 
> > > +			   TUN_SOCKET__RELABELTO, NULL);
> > > +	if (err)
> > > +		return err;
> > > +
> > > +	sksec->sid = sid;
> > > +
> > > +	return 0;
> > > +}
> >
> > IIUC it is possible for multiple processes to attach to the same
> > tun device.  Will it get confusing/incorrect to have each attach
> > potentially (if tasks have different sids) relabel?
> 
> I may be reading the code wrong, but in drivers/net/tun.c:tun_attach() the 
> code checks to see if the TUN device is already in use and if it is then the 
> attach fails with -EBUSY (check where the tun_device->tfile is examined).  I 

Ah yes, you're right - I saw the check for (ifr->ifr_flags & IFF_TUN_EXCL) in
the attach path in tun_set_iff, and missed this one.

> believe this should ensure that only one process at a time has access to the 
> TUN device so we shouldn't have to worry about a TUN socket getting relabeled 
> while it is currently in use.  As far as persistent TUN devices getting 
> relabeled when a new process attaches to them, that is what we are trying to 
> accomplish here so that the network traffic being sent via the TUN device is 
> labeled according to the currently attached process; this is consistent with 
> how SELinux currently labels locally generated outbound traffic - outbound 
> packets inherit their security label from the sending process via the 
> originating socket/sock.

Ok, thanks.  To my untrained eye the class addition looks right too, so
with the trivial change:

Acked-by: Serge Hallyn <serue@us.ibm.com>

thanks,
-serge
