From: Paolo Abeni <pabeni@redhat.com>
Subject: Re: [RFC PATCH 0/2] selinux: avoid nf hooks overhead when not needed
Date: Thu, 07 Apr 2016 09:59:14 +0200
Message-ID: <1460015954.13054.23.camel@redhat.com>
References: <cover.1459934322.git.pabeni@redhat.com>
	 <570582FC.7030807@schaufler-ca.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-security-module@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	James Morris <james.l.morris@oracle.com>,
	Paul Moore <paul@paul-moore.com>,
	Andreas Gruenbacher <agruenba@redhat.com>,
	Stephen Smalley <sds@tycho.nsa.gov>,
	Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org,
	selinux@tycho.nsa.gov
To: Casey Schaufler <casey@schaufler-ca.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <570582FC.7030807@schaufler-ca.com>
Sender: owner-linux-security-module@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Casey,

On Wed, 2016-04-06 at 14:43 -0700, Casey Schaufler wrote:
> On 4/6/2016 2:51 AM, Paolo Abeni wrote:
> > Currently, selinux always registers iptables POSTROUTING hooks regarless of
> > the running policy needs for any action to be performed by them.
> >
> > Even the socket_sock_rcv_skb() is always registered, but it can result in a no-op
> > depending on the current policy configuration.
> >
> > The above invocations in the kernel datapath are cause of measurable
> > overhead in networking performance test.
> >
> > This patch series adds explicit notification for netlabel status change 
> > (other relevant status change, like xfrm and secmark, are already notified to
> > LSM) and use this information in selinux to register the above hooks only when
> > the current status makes them relevant, deregistering them when no-op
> >
> > Avoiding the LSM hooks overhead, in netperf UDP_STREAM test with small packets,
> > gives about 5% performance improvement on rx and about 8% on tx.
> >
> > Paolo Abeni (2):
> >   security: add hook for netlabel status change notification
> >   selinux: implement support for dynamic net hook [de-]registration

Thank you for the feedback. The patch series is an RFC, so it's still
rough and not yet well tested in all possible scenarios.

> Did you consider the fact that netlabel and the LSM socket
> hooks are used by Smack as well as SELinux? 

Actually yes. The patch series itself is explicitly targeted at reducing
some overhead introduced by selinux in network loads (I'm sorry, now I
see that the last sentence in the cover letter is misleading), and it
tries to achieve that result without affecting others LSM users.

The first patch in the series just introduces an optional LSM hook
(netlbl_changed) that is invoked every time the
'netlabel_mgmt_protocount' values is changed. It do not modify the
behavior nor meaning of any of the existing hooks and/or netlabel APIs.
It's up to the security module to leverage (or not) the new one.

> Did you measure the impact that your changes have on Smack? 

Actually I didn't. This is one of the reasons I posted the patch as RFC.
As per design security modules not implementing 'netlbl_changed' should
not be affected. Am I missing something ?

Regards,

Paolo

