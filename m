From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] Fixed zero copy GSO without orphaning the fragments
Date: Tue, 03 Jun 2014 06:49:45 -0700
Message-ID: <1401803385.3645.201.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CAKyyzSRfO_Hw4bDimfzV9+-8damc9RwoqA_RLkBBa_gMw9e62Q@mail.gmail.com>
	 <20140601122152.GB22450@redhat.com>
	 <CAKyyzSSs1PUfJXTPDWTbWU5p+b54qti_N_6kR6mJWWrp__rykw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Tom Herbert <therbert@google.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Simon Horman <horms@verge.net.au>,
	Joe Perches <joe@perches.com>, Jiri Pirko <jiri@resnulli.us>,
	Florian Westphal <fw@strlen.de>,
	Paul Durrant <Paul.Durrant@citrix.com>,
	Thomas Graf <tgraf@suug.ch>, Jan Beulich <JBeulich@suse.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Miklos Szeredi <mszeredi@suse.cz>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Anton Nayshtut <anton@swortex.com>
To: Igor Royzis <igorr@swortex.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAKyyzSSs1PUfJXTPDWTbWU5p+b54qti_N_6kR6mJWWrp__rykw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2014-06-03 at 14:54 +0300, Igor Royzis wrote:
> Eric, could you please provide a feedback on the suggestion to move
> the pointer from skb_shared_info to skbuff? If we must fit
> skb_shared_info till the 'frags' field into 1 cache line (I honestly
> don't quite understand why (the whole structure as well as the skb's
> data will always require > 1 cache line anyway)  and I would
> appreciate if you elaborate on this more), then moving the pointer to
> the parent fragment off skb_shared_info should help. Am I right?


Have you tried this idea and cook a patch ?
It seems quite complex, but maybe you have a pretty clear idea.

> 
> The pointer is essential if we want to solve the incorrect way the
> kernel handles a combination of packet segmentation (of any reason, in
> our case it was a VM guest not supporting GRO) and zero-copy feature.
> Disabling zero-copy for segmented packets is a workaround but an
> efficient solution would require either:
> a) a pointer in skb_shared_info, or
> b) a pointer in skbuff,  or
> c) reusing a [currently unused] existing pointer/field in a skb
> structure, which is a bad idea and I list it for completeness only.
> 
> Please comment,

It's nice you guys want nice numbers for bulk flows sending at line
rate, but many networking workloads handle thousands of flows, if not
more, and small to medium packet sizes. Its critical for them to keep
skb overhead as small as possible.

My understanding of this zero copy stuff and GSO is that you need a
refcounter, not in the skb or skb_shared_info, but in the structure that
describes the zero copy stuff. This way, the overhead of this extra
refcounting (still a win for you compared to 'orphaning fragments'), is
only paid for this special case.
