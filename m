From: Jouni Malinen <jkmaline@cc.hut.fi>
Subject: Re: linux-wireless mailing list
Date: Thu, 4 Mar 2004 20:08:25 -0800
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20040305040824.GA3980@jm.kir.nu>
References: <Pine.LNX.4.58.0403031656090.22365@marabou.research.att.com> <20040303233343.GA14803@bougret.hpl.hp.com> <Pine.LNX.4.58.0403040100300.4248@portland.hansa.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jt@hpl.hp.com, linux-net@vger.kernel.org, netdev@oss.sgi.com
Return-path: <linux-net-owner@vger.kernel.org>
To: Pavel Roskin <proski@gnu.org>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.58.0403040100300.4248@portland.hansa.lan>
List-Id: netdev.vger.kernel.org

On Thu, Mar 04, 2004 at 02:08:08AM -0500, Pavel Roskin wrote:

> On Wed, 3 Mar 2004, Jean Tourrilhes wrote:
> > 	Actually, you remind me that I should ask Jouni to push his
> > driver in the kernel.

> I believe it can happen after RC4 goes to the kernel and HostAP uses
> crypto API (optionally in the standalone version to keep Linux 2.4
> compatibility).

Yes, it is quite easy for me to replace the HostAP-internal
implementation of WEP with CRC32+RC4 with crypto API. However, the
encryption algorithm itself is not everything that is needed for IEEE
802.11 encryption. With WEP, the additional work is quite limited (add
IV, verify ICV), but both TKIP and CCMP add quite a bit of more
processing for the header (like authentication of pseudo header, replay
protection, etc.).

Host AP driver uses a structure which allows multiple algorithms to be
registered for both encrypting and decrypting skb's with IEEE 802.11
headers. This structure is likely to remain even when the encryption
parts themselves are replaced with crypto API. In addition, these
functions are completely separate from the rest of the Host AP driver,
so it should be easy for other drivers to use them, if desired.

Some wlan chipsets use hardware acceleration for the
WEP/TKIP/CCMP(AES-CCM), but require the driver to process the IV/ICV/MIC
addition/verification. These drivers would also benefit if there were
generic functions that would support both software and hwaccel versions
for the encryption/decryption.

I was looking into pushing Host AP code for the kernel tree, but since
non-trivial amount of work would have been required with crypto parts,
this was delayed. Then came WPA and I wanted to get it working first..
But maybe now that it is mostly done, I could try to allocate enough
time to go through what is needed to get Host AP driver in acceptable
shape to be included into the kernel tree.

> > > Encryption.  There are wireless specific encryption issues.  Host based
> > > WEP support needs RC4 cipher in the kernel.  There's not much to discuss
> > > here, but the lack of RC4 in the kernel may indicate that Linux wireless
> > > developers are not acting together to make it happen.  The patch does
> > > exist.
> >
> > 	I've never seen this patch. Was it sent to the Crypto guys ?
> 
> http://sourceforge.net/mailarchive/message.php?msg_id=7298902

That's nice to see. However, I would like to know whether any
performance testing has been done with that kind of design? It looks
like the encryption function (arc4_crypt()) is being called for each
byte of the encrypted area. That looks like a major extra work compared
to a tight loop going through the data (e.g., compared to the integrated
CRC32+RC4 implementation in Host AP driver).

With IEEE 802.11b, I don't really are that much about the extra work,
but with throughput of IEEE 802.11a/g, this might become considerable.
Then again, most modern cards seem to include hardware acceleration and
some of them are even able to do this at full data rate. Anyway,
software encryption might still be needed for some configuration (like
individual keys or some of more exotic things one can do with IEEE
802.11). For these cases, it would be nice to have crypto API support
for scatter-gather lists and going through each fragment with one
function call.

I'll try to get some time to test this with Host AP driver with WEP and
TKIP (by first implementing Michael MIC with crypto API). I will also
need to do some experimenting with AES and CCMP. With good luck, that
could be enough to replace internal crypto algorithm code in the Host AP
driver.

-- 
Jouni Malinen                                            PGP id EFC895FA
