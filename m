From: Stephen Smalley <sds@epoch.ncsc.mil>
Subject: Re: [PATCH] Add audit uid to netlink credentials
Date: Thu, 10 Feb 2005 07:36:09 -0500
Message-ID: <1108038968.22172.26.camel@moss-spartans.epoch.ncsc.mil>
References: <20050204165840.GA2320@IBM-BWN8ZTBWA01.austin.ibm.com>
	 <1107958621.19262.524.camel@hades.cambridge.redhat.com>
	 <1107960659.4837.9.camel@serge>
	 <1107973381.17568.97.camel@moss-spartans.epoch.ncsc.mil>
	 <20050209103747.Y24171@build.pdx.osdl.net>
	 <1107974448.17568.108.camel@moss-spartans.epoch.ncsc.mil>
	 <20050209153816.B24171@build.pdx.osdl.net>
	 <20050209171115.G24171@build.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Linux Audit Discussion <linux-audit@redhat.com>,
        davem@davemloft.net, kuznet@ms2.inr.ac.ru
To: Chris Wright <chrisw@osdl.org>
In-Reply-To: <20050209171115.G24171@build.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 2005-02-09 at 20:11, Chris Wright wrote:
> * Chris Wright (chrisw@osdl.org) wrote:
> > Hmm, perhaps we could eliminate the whole asynchronous issue by allowing
> > registration of a netlink link specific security handler.  Something like:
> > 
> > netlink_kernel_create_sec(unit, rx, sec_handler)
> > 
> > Then the check would be done before the packet was ever queued.  This
> > would eliminate the if (NETLINK_CREDS(skb)->$cred == bad) on receipt
> > side, and push it to sender side.  It would also be link specific so
> > audit could do it's audit payload loginuid check here.  I think it would
> > also eliminate SELinux's need to tag the packet for later checking on
> > receipt.  Thoughts?
> 
> Here's an example of what I mean.  It's quite rough, doesn't yet eliminate
> any of the code that it eventually could, and doesn't deal with broadcast.
> I gave it a quick test with audit netlink, and it does what I expect.

Why not just call the security handler from the security_netlink_send()
function, which is already called by netlink_sendmsg()?  Note that
SELinux (thanks to work by James Morris a while back) does apply
fine-grained netlink controls using its selinux_netlink_send() hook
function, but the problem with this approach is that it requires
maintaining a netlink message type table within SELinux itself that maps
netlink operations to generic flow operations (read, write), effectively
duplicating state between SELinux and the netlink protocol
implementations.  It also isn't necessarily sufficiently granular for
all needs.  It would be preferable to have the netlink protocol
implementations to maintain such mappings and just invoke security
modules to check the generic permissions based on its own internal
mapping (same idea applies for ioctls, where the device driver or
filesystem code should handle the mapping to generic permissions and
only invoke the security module to check the generic permission).

-- 
Stephen Smalley <sds@epoch.ncsc.mil>
National Security Agency
