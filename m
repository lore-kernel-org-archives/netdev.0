From: Chris Wright <chrisw@osdl.org>
Subject: Re: [PATCH] Add audit uid to netlink credentials
Date: Wed, 9 Feb 2005 15:38:16 -0800
Message-ID: <20050209153816.B24171@build.pdx.osdl.net>
References: <20050204165840.GA2320@IBM-BWN8ZTBWA01.austin.ibm.com> <1107958621.19262.524.camel@hades.cambridge.redhat.com> <1107960659.4837.9.camel@serge> <1107973381.17568.97.camel@moss-spartans.epoch.ncsc.mil> <20050209103747.Y24171@build.pdx.osdl.net> <1107974448.17568.108.camel@moss-spartans.epoch.ncsc.mil>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Audit Discussion <linux-audit@redhat.com>, netdev@oss.sgi.com,
        davem@davemloft.net, kuznet@ms2.inr.ac.ru
To: Stephen Smalley <sds@epoch.ncsc.mil>
Content-Disposition: inline
In-Reply-To: <1107974448.17568.108.camel@moss-spartans.epoch.ncsc.mil>; from sds@epoch.ncsc.mil on Wed, Feb 09, 2005 at 01:40:48PM -0500
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Stephen Smalley (sds@epoch.ncsc.mil) wrote:
> On Wed, 2005-02-09 at 13:37, Chris Wright wrote:
> > This means sendmsg hook would set the SID?  And in that case, you'd
> > stomp on loginuid for audit messages unless they are special cased.
> 
> I was referring to a separate field for use by security modules, not
> re-use of the same field being proposed for the loginuid.  Yes, it would
> be set by the security_netlink_send hook.  The principal problem with
> such a security field is that unless we mandate it to be a simple
> integer value (like a SELinux SID), we have to deal with lifecycle
> management for it, i.e. a set of hooks that starts to look like the
> sk_buff security hooks from the old LSM patch.  But if we can limit it
> to a simple value, then it would be useful for such security
> identifiers, and allow receiver-side permission checks based on the
> sender SID.

This makes sense to me.  Just an extension of existing eff_cap and would
be used by security modules for each netlink packet.

> > The loginuid is special case to audit, it doesn't make sense to me that
> > it is in generic netlink_skb_parms structure unless it's used by more
> > netlink users.
> 
> So you also think it should be in the payload?  That would require
> security_netlink_send to dig into the payload if we wanted to control
> who can specify other loginuids, as Serge noted.

I just don't see it making sense to add another credential for a special
case.  The signal code already peaks into the siginfo struct when queueing
a signal to make sure some user isn't trying to send si_code == SI_KERNEL
or similar.  Perhaps audit could do that with it's own payload during send.
No matter how we slice it, it's a special case.

Hmm, perhaps we could eliminate the whole asynchronous issue by allowing
registration of a netlink link specific security handler.  Something like:

netlink_kernel_create_sec(unit, rx, sec_handler)

Then the check would be done before the packet was ever queued.  This
would eliminate the if (NETLINK_CREDS(skb)->$cred == bad) on receipt
side, and push it to sender side.  It would also be link specific so
audit could do it's audit payload loginuid check here.  I think it would
also eliminate SELinux's need to tag the packet for later checking on
receipt.  Thoughts?

thanks,
-chris
-- 
Linux Security Modules     http://lsm.immunix.org     http://lsm.bkbits.net
