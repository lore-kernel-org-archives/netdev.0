From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH 1/2] net: Toeplitz library functions
Date: Tue, 24 Sep 2013 08:22:55 -0700
Message-ID: <CA+mtBx_y0hK69jcdY5e0MUzAa8hEPwExBDuK9Dn4Ceo5Hkn_iw@mail.gmail.com>
References: <alpine.DEB.2.02.1309231535030.23896@tomh.mtv.corp.google.com>
	<AE90C24D6B3A694183C094C60CF0A2F6026B7355@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>
To: David Laight <David.Laight@aculab.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f179.google.com ([209.85.223.179]:46173 "EHLO
	mail-ie0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753656Ab3IXPW4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Sep 2013 11:22:56 -0400
Received: by mail-ie0-f179.google.com with SMTP id e14so8834727iej.24
        for <netdev@vger.kernel.org>; Tue, 24 Sep 2013 08:22:56 -0700 (PDT)
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B7355@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 24, 2013 at 1:32 AM, David Laight <David.Laight@aculab.com> wrote:
>> +static inline unsigned int
>> +toeplitz_hash(const unsigned char *bytes,
>> +           struct toeplitz *toeplitz, int n)
>> +{
>> +     int i;
>> +     unsigned int result = 0;
>> +
>> +     for (i = 0; i < n; i++)
>> +             result ^= toeplitz->key_cache[i][bytes[i]];
>> +
>> +        return result;
>> +};
>
> That is a horrid hash function to be calculating in software.
>
> The code looks very much like a simple 32bit CRC.
> It isn't entirely clears exactly where the 'key' gets included,
> but I suspect it is just xored with the data bytes.
>
Please google Toeplitz hash function to learn about the algorithm.
http://msdn.microsoft.com/en-us/library/windows/hardware/ff570725(v=vs.85).aspx

> Using in it hardware is probably fine - the hardware can do
> it cheaply (in dedicated logic) as the frame arrives.
> The CRC polynomial probably collapses to a few XOR operations
> when done byte by byte (the hdlc crc16 collapses to 3 levels
> of xor).
>
> IIRC jhash() works on 32bit quantities - so has far fewer
> maths operations and well as not having all the random data
> accesses (cache misses and displacing other parts of the
> working set from the cache).
>
Yes, but pretty much every NIC vendor implements Toeplitz hash and
provides it in their receive descriptor.  We use this value for
steering, and could use it for other uses like connection lookup.

> I also thought the hash was arranged so that tx and rx packets
> for a single connection hash to the same value?
>
ehashfn hashes consistently based on local and remote sides.
skb_get_rxhash orders the addresses and ports to make a consistent
hash in both directions. Presumably, this allows skb_get_rxhash to be
called from TX side to get same value of RX side, but when we get
rxhash from device (e.g. Toeplitz) this property is broken anyway.
Instead of jumping through this hoop, it might be better to have a
separate function from calculating RX hash for reverse path on TX.

Assuming skb_rx_hash does symmetric calculation is currently
incorrect.  For instance, looks like tun.c is trying to implement a
sort of 'flow director' logic to pair TX queues and RX queues using
skb_get_rxhash an expecting that the value is calculated
symmetrically.  If HW is providing RX hash, this is broken and we'll
never match the flows.  We could either recompute the hash in SW or
try to match HW hash.

Tom

>         David
>
>
>
