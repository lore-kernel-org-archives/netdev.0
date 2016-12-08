From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Misalignment, MIPS, and ip_hdr(skb)->version
Date: Thu, 8 Dec 2016 01:30:34 +0100
Message-ID: <095cac5b-b757-6f4a-e699-8eedf9ed7221@stressinduktion.org>
References: <CAHmME9o_eCNXpVztOZKW55kpRtE+1KSEQTQOjUBVn68Y2+or2g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
 WireGuard mailing list <wireguard@lists.zx2c4.com>
To: "Jason A. Donenfeld" <Jason@zx2c4.com>, Netdev <netdev@vger.kernel.org>,
 linux-mips@linux-mips.org
Return-path: <wireguard-bounces@lists.zx2c4.com>
In-Reply-To: <CAHmME9o_eCNXpVztOZKW55kpRtE+1KSEQTQOjUBVn68Y2+or2g@mail.gmail.com>
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

Hi Jason,

On 07.12.2016 19:35, Jason A. Donenfeld wrote:
> I receive encrypted packets with a 13 byte header. I decrypt the
> ciphertext in place, and then discard the header. I then pass the
> plaintext to the rest of the networking stack. The plaintext is an IP
> packet. Due to the 13 byte header that was discarded, the plaintext
> possibly begins at an unaligned location (depending on whether
> dev->needed_headroom was respected).
> 
> Does this matter? Is this bad? Will there be a necessary performance hit?

Your custom protocol should be designed in a way you get an aligned ip
header. Most protocols of the IETF follow this mantra and it is always
possible to e.g. pad options so you end up on aligned boundaries for the
next header.

GRE-TEB for example needs skb_copy_bits to extract the header so it can
access them in an aligned way.

> In order to find out, I instrumented the MIPS unaligned access
> exception handler to see where I was actually in trouble.
> Surprisingly, the only part of the stack that seemed to be upset was
> on calls to ip_hdr(skb)->version.
> 
> Two things disturb me about this. First, this seems too good to be
> true. Does it seem reasonable to you that this is actually the only
> place that would be problematic? Or was my testing methodology wrong
> to arrive at such an optimistic conclusion?
> 
> Secondly, why should a call to ip_hdr(skb)->version cause an unaligned
> access anyway? This struct member is simply the second half of a
> single byte in a bit field. I'd expect for the compiler to generate a
> single byte load, followed by a bitshift or a mask. Instead, the
> compiler appears to generate a double byte load, hence the exception.
> What's up with this? Stupid compiler that should be fixed? Some odd
> optimization? What to do?

I don't see an issue with that at all. Why do you think it could be a
problem?

Bye,
Hannes
