From: Felix Fietkau <nbd@nbd.name>
Subject: Re: Misalignment, MIPS, and ip_hdr(skb)->version
Date: Sat, 10 Dec 2016 13:25:07 +0100
Message-ID: <040bcdb2-2725-c8de-11d9-a4f77b75d9d8@nbd.name>
References: <CAHmME9o_eCNXpVztOZKW55kpRtE+1KSEQTQOjUBVn68Y2+or2g@mail.gmail.com>
 <CAA93jw7hcmkcyD=t4VRrQFfHk+n+EkSVgY6KFDq0_-DGpMADYw@mail.gmail.com>
 <20161207.135127.789629809982860453.davem@davemloft.net>
 <CAHmME9oLgjDA2F0gkFzHU2Es8-XCxQHRABS18OKF0EnZgt1=LQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>,
 WireGuard mailing list <wireguard@lists.zx2c4.com>,
 LKML <linux-kernel@vger.kernel.org>, linux-mips@linux-mips.org
To: "Jason A. Donenfeld" <Jason@zx2c4.com>, David Miller <davem@davemloft.net>
Return-path: <wireguard-bounces@lists.zx2c4.com>
In-Reply-To: <CAHmME9oLgjDA2F0gkFzHU2Es8-XCxQHRABS18OKF0EnZgt1=LQ@mail.gmail.com>
List-Unsubscribe: <https://lists.zx2c4.com/mailman/options/wireguard>,
 <mailto:wireguard-request@lists.zx2c4.com?subject=unsubscribe>
List-Archive: <http://lists.zx2c4.com/pipermail/wireguard/>
List-Post: <mailto:wireguard@lists.zx2c4.com>
List-Help: <mailto:wireguard-request@lists.zx2c4.com?subject=help>
List-Subscribe: <https://lists.zx2c4.com/mailman/listinfo/wireguard>,
 <mailto:wireguard-request@lists.zx2c4.com?subject=subscribe>
Errors-To: wireguard-bounces@lists.zx2c4.com
Sender: "WireGuard" <wireguard-bounces@lists.zx2c4.com>
List-Id: netdev.vger.kernel.org

On 2016-12-07 19:54, Jason A. Donenfeld wrote:
> On Wed, Dec 7, 2016 at 7:51 PM, David Miller <davem@davemloft.net> wrote:
>> It's so much better to analyze properly where the misalignment comes from
>> and address it at the source, as we have for various cases that trip up
>> Sparc too.
> 
> That's sort of my attitude too, hence starting this thread. Any
> pointers you have about this would be most welcome, so as not to
> perpetuate what already seems like an issue in other parts of the
> stack.
Hi Jason,

I'm the author of that hackish LEDE/OpenWrt patch that works around the
misalignment issues. Here's some context regarding that patch:

I intentionally put it in the target specific patches for only one of
our MIPS targets. There are a few ar71xx devices where the misalignment
cannot be fixed, because the Ethernet MAC has a 4-byte DMA alignment
requirement, and does not support inserting 2 bytes of padding to
correct the IP header misalignment.

With these limitations the choice was between this ugly network stack
patch or inserting a very expensive memmove in the data path (which is
better than taking the mis-alignment traps, but still hurts routing
performance significantly).

There are a lot of places in the network stack that assume full 32 bit
alignment, and you only get to see those once you start using more of
netfilter, play with various tunnel encapsulations, etc.

I think you have 3 options to deal with this properly:
1. add 3 bytes of padding
2. allocate a separate skb for decryption (might be more expensive)
3. save the header and decrypt to the start of the packet data
(overwriting the misaligned header).

I'm not sure what the performance impact of 2 and 3 is, so it's probably
best to stick with the padding.

I've taken a quick look at the wireguard message headers, and my
recommendation would be to insert the 3-byte padding in struct
message_header and remove __packed from your structs.
This will also remove misaligment of your own protocol fields.

- Felix
