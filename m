From: Adrian Chadd <adrian@freebsd.org>
Subject: Re: [PATCH 1/3] ath10k: remove ath10k_vif_to_arvif()
Date: Fri, 10 Feb 2017 07:31:58 -0800
Message-ID: <CAJ-Vmo=UrnDVzGAKYZa0qXq5UVb09AZHzmWMtctvtXyu==nzyA@mail.gmail.com>
References: <1486030773-30600-1-git-send-email-amadeusz.slawinski@tieto.com>
 <CAJ-VmonrHpS3MArM9ohHgLvb6xspP_gnVVeJWA9F-pjUpJ+LZA@mail.gmail.com>
 <87y3xi4b28.fsf@qca.qualcomm.com> <5899DDD7.7000605@candelatech.com>
 <87tw82il32.fsf@kamboji.qca.qualcomm.com>
 <CAJ-Vmom7k3Tsgs8tRHQppmL7XxADS3V24AGOQY5QgkrSgr5Qzg@mail.gmail.com>
 <1486712222.2192.3.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
 =?UTF-8?B?QW1hZGV1c3ogU8WCYXdpxYRza2k=?= <amadeusz.slawinski@tieto.com>,
 "ath10k@lists.infradead.org" <ath10k@lists.infradead.org>,
 Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "Valo,
 Kalle" <kvalo@qca.qualcomm.com>, Ben Greear <greearb@candelatech.com>
To: Joe Perches <joe@perches.com>
Return-path: <ath10k-bounces+gldad-ath10k=m.gmane.org@lists.infradead.org>
In-Reply-To: <1486712222.2192.3.camel@perches.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/ath10k>,
 <mailto:ath10k-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/ath10k/>
List-Post: <mailto:ath10k@lists.infradead.org>
List-Help: <mailto:ath10k-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/ath10k>,
 <mailto:ath10k-request@lists.infradead.org?subject=subscribe>
Sender: "ath10k" <ath10k-bounces@lists.infradead.org>
Errors-To: ath10k-bounces+gldad-ath10k=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

On 9 February 2017 at 23:37, Joe Perches <joe@perches.com> wrote:
> On Thu, 2017-02-09 at 23:14 -0800, Adrian Chadd wrote:
>
>> If there
>> were accessors for the skb data / len fields (like we do for mbufs)
>> then porting the code would've involved about 5,000 less changed
>> lines.
>
> What generic mechanisms would you suggest to make
> porting easier between bsd and linux and what in
> your opinion are the best naming schemes to make
> these functions easiest to read and implement
> without resorting to excessive identifier lengths?
>
> If you have some, please provide examples.

(Why not, it's pre-coffee o'clock.)

The biggest barriers are direct struct accessors. Most of the time the
kernels have similar enough semantics that I can just implement a
linux shim layer (like we do for graphics layer porting from Linux.)
Eg, having skb_data(skb) (and skb_data_const(skb)) + skb_len(skb)
instead of skb->data and skb->len would remove a lot of churn. Having
say, a vif_to_drvpriv() method analogous to ath10k_vif_to_arvif()
would also simplify the changes. For the rest of it we can just use a
linux-like shim layer to get everything else working pretty darn well.

But the biggest thing that helps is a quasi HAL code structure. I know
HAL is a dirty word, so think of it more as "how would one separate
out the OS interface layer from the rest of the driver." A good
example in ath10k is the difference between say, wmi.c, the pci /
copyengine code and mac.c.

* the pci / copyengine code is almost 100% compilable on other
platforms, save the differences in little things (malloc, free, KVA
versus physical memory allocation, bounce buffering, sync'ing, etc.) A
sufficiently refactored driver like ath10k where almost all of that
stuff happens in the pci/copyengine code made porting that much less
painful.

* the wmi code is almost exclusively portable - besides the
malloc/free, etc mechanical changes which honestly can be stubbed, it
uses the lower layers (pci/ce, hif, htc, etc) for doing actual work,
and the upper layer uses a well-defined API + callback mechanism for
getting work done. Porting that was mechanical but reasonably easy.

* however, the mac.c code contains both code which sends commands to
the firmware (vif create/destroy, pdev commands, station
associate/update/destroy, crypto key handling, peer rate control, etc)
/and/ very linux mac80211/cfg80211 specific bits. If mac.c were split
into mac-mac80211.c (which was /just/ mac80211, cfg80211, etc bits)
and mac-utils.c (the bits that actually /sent/ the commands,
responses, all the support code, etc) then my port would just
implement mac-net80211.c as a completely new file, and the rest would
just be modified as required by porting.

A lot of the ath10k headers too mix linux specific things (eg struct
device, dependencies) with hardware specific definitions for say,
register accesses. I split out the register and firmware command /
structures into separate header files that didn't mingle OS and driver
specific structures to make it much easier to reuse that code. I find
that good driver writing hygiene in any case.

I'm not expecting an intel ethernet driver style HAL separation,
although that'd certainly make life easier in porting over drivers.
But just having inlined accessor functions for most things and some
stricter driver structure for OS touch points (dma setup/teardown,
bounce buffer stuff, mac80211/cfg80211, ethtool, etc APIs) would make
porting and testing things a lot easier. :-)

2c, and I'll do the porting/reimplementing work anyway regardless of
how much coffee it requires,



-adrian
