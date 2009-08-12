From: Paul Moore <paul.moore@hp.com>
Subject: Re: [RFC PATCH v2 2/2] selinux: Support for the new TUN LSM hooks
Date: Wed, 12 Aug 2009 18:55:23 -0400
Message-ID: <200908121855.24061.paul.moore@hp.com>
References: <20090810172238.7946.34247.stgit@flek.lan> <20090810172850.7946.25175.stgit@flek.lan> <20090812221440.GA8524@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-security-module@vger.kernel.org, netdev@vger.kernel.org,
	selinux@tycho.nsa.gov
To: "Serge E. Hallyn" <serue@us.ibm.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20090812221440.GA8524@us.ibm.com>
Content-Disposition: inline
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 12 August 2009 06:14:40 pm Serge E. Hallyn wrote:
> Quoting Paul Moore (paul.moore@hp.com):
> > +static int selinux_tun_dev_attach(struct sock *sk)
> > +{
> > +	struct sk_security_struct *sksec = sk->sk_security;
> > +	u32 sid = current_sid();
> > +	int err;
> > +
> > +	err = avc_has_perm(sid, sksec->sid, SECCLASS_TUN_SOCKET,
> > +			   TUN_SOCKET__RELABELFROM, NULL);
> > +	if (err)
> > +		return err;
> > +	err = avc_has_perm(sid, sid, SECCLASS_RAWIP_SOCKET,
>
> Was RAWIP on purpose here?

Nope, a mistake on my part that I hadn't caught yet.  Thanks.

> > +			   TUN_SOCKET__RELABELTO, NULL);
> > +	if (err)
> > +		return err;
> > +
> > +	sksec->sid = sid;
> > +
> > +	return 0;
> > +}
>
> IIUC it is possible for multiple processes to attach to the same
> tun device.  Will it get confusing/incorrect to have each attach
> potentially (if tasks have different sids) relabel?

I may be reading the code wrong, but in drivers/net/tun.c:tun_attach() the 
code checks to see if the TUN device is already in use and if it is then the 
attach fails with -EBUSY (check where the tun_device->tfile is examined).  I 
believe this should ensure that only one process at a time has access to the 
TUN device so we shouldn't have to worry about a TUN socket getting relabeled 
while it is currently in use.  As far as persistent TUN devices getting 
relabeled when a new process attaches to them, that is what we are trying to 
accomplish here so that the network traffic being sent via the TUN device is 
labeled according to the currently attached process; this is consistent with 
how SELinux currently labels locally generated outbound traffic - outbound 
packets inherit their security label from the sending process via the 
originating socket/sock.

-- 
paul moore
linux @ hp

