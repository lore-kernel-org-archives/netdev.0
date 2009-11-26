From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 1/4] veth: move loopback logic to common location
Date: Thu, 26 Nov 2009 16:33:36 +0100
Message-ID: <4B0E9FD0.4040107@trash.net>
References: <1259024166-28158-1-git-send-email-arnd@arndb.de> <m1aayb6bfg.fsf@fess.ebiederm.org> <4B0C2824.5010502@trash.net> <200911261621.28298.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	virtualization@lists.linux-foundation.org,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Anna Fischer <anna.fischer@hp.com>, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org, linux-kernel@vger.kernel.org,
	Mark Smith <lk-netdev@lk-netdev.nosense.org>,
	Gerhard Stenzel <gerhard.stenzel@de.ibm.com>,
	Jens Osterkamp <jens@linux.vnet.ibm.com>,
	Patrick Mullaney <pmullaney@novell.com>,
	Stephen Hemminger <shemminger@vyatta.com>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756207AbZKZPdg@vger.kernel.org>
In-Reply-To: <200911261621.28298.arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Arnd Bergmann wrote:
> On Tuesday 24 November 2009, Patrick McHardy wrote:
>> Eric W. Biederman wrote:
>>> I don't quite follow what you intend with dev_queue_xmit when the macvlan
>>> is in one namespace and the real physical device is in another.  Are
>>> you mentioning that the packet classifier runs in the namespace where
>>> the primary device lives with packets from a different namespace?
>> Exactly. And I think we should make sure that the namespace of
>> the macvlan device can't (deliberately or accidentally) cause
>> misclassification.
> 
> This is independent of my series and a preexisting problem, right?

Correct.

> Which fields do you think need to be reset to maintain namespace
> isolation for the outbound path in macvlan?

In addition to those already handled, I'd say

- priority: affects qdisc classification, may refer to classes of the
  old namespace
- ipvs_property: might cause packets to incorrectly skip netfilter hooks
- nf_trace: might trigger packet tracing
- nf_bridge: contains references to network devices in the old NS,
  also indicates packet was bridged
- iif: index is only valid in the originating namespace
- tc_index: classification result, should only be set in the namespace
  of the classifier
- tc_verd: RTTL etc. should begin at zero again
- probably secmark.
