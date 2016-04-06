From: Paul Moore <paul@paul-moore.com>
Subject: Re: [RFC PATCH 0/2] selinux: avoid nf hooks overhead when not needed
Date: Wed, 6 Apr 2016 08:33:37 -0400
Message-ID: <CAHC9VhS6aJdPR6xTH2-ehikS5qvj6jFbZAUtzoBXp+WC9Ugi=Q@mail.gmail.com>
References: <cover.1459934322.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-security-module@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	James Morris <james.l.morris@oracle.com>,
	Andreas Gruenbacher <agruenba@redhat.com>,
	Stephen Smalley <sds@tycho.nsa.gov>,
	Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org,
	selinux@tycho.nsa.gov
To: Paolo Abeni <pabeni@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f194.google.com ([209.85.214.194]:35586 "EHLO
	mail-ob0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932181AbcDFMdi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Apr 2016 08:33:38 -0400
Received: by mail-ob0-f194.google.com with SMTP id 4so3459996obi.2
        for <netdev@vger.kernel.org>; Wed, 06 Apr 2016 05:33:38 -0700 (PDT)
In-Reply-To: <cover.1459934322.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 6, 2016 at 5:51 AM, Paolo Abeni <pabeni@redhat.com> wrote:
> Currently, selinux always registers iptables POSTROUTING hooks regarless of
> the running policy needs for any action to be performed by them.
>
> Even the socket_sock_rcv_skb() is always registered, but it can result in a no-op
> depending on the current policy configuration.
>
> The above invocations in the kernel datapath are cause of measurable
> overhead in networking performance test.
>
> This patch series adds explicit notification for netlabel status change
> (other relevant status change, like xfrm and secmark, are already notified to
> LSM) and use this information in selinux to register the above hooks only when
> the current status makes them relevant, deregistering them when no-op
>
> Avoiding the LSM hooks overhead, in netperf UDP_STREAM test with small packets,
> gives about 5% performance improvement on rx and about 8% on tx.

[NOTE: added the SELinux mailing list to the CC line, please include
when submitting SELinux patches]

While I appreciate the patch and the work that went into development
and testing, I'm going to reject this patch on the grounds that it
conflicts with work we've just started thinking about which should
bring some tangible security benefit.

The recent addition of post-init read only memory opens up some
interesting possibilities for SELinux and LSMs in general, the thing
which we've just started looking at is marking the LSM hook structure
read only after init.  There are some complicating factors for
SELinux, but I'm confident those can be resolved, and from what I can
tell marking the hooks read only will have no effect on other LSMs.
While marking the LSM hook structure doesn't directly affect the
SELinux netfilter hooks, once we remove the ability to deregister the
LSM hooks we will have no need to support deregistering netfilter
hooks and I expect we will drop that functionality as well to help
decrease the risk of tampering.

-- 
paul moore
www.paul-moore.com
