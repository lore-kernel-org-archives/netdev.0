From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: Sending short raw packets using sendmsg() broke
Date: Sat, 27 Feb 2016 18:02:23 -0500
Message-ID: <CAF=yD-+m09_KS9+SyMZsTES5iLPyVE10F0u6pt4tVeYcDk8=PQ@mail.gmail.com>
References: <20160225.152628.1230785666614750970.davem@davemloft.net>
 <1456497874.7064.7.camel@linux.intel.com> <CAF=yD-JOQZZnU6XE9FhEVbxstKmsB-ds58e5v678SiO24VV0+g@mail.gmail.com>
 <20160226.124645.2123990166666725876.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alan Cox <alan@linux.intel.com>,
	Heikki Hannikainen <hessu@hes.iki.fi>,
	Network Development <netdev@vger.kernel.org>,
	Willem de Bruijn <willemb@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f170.google.com ([209.85.217.170]:35048 "EHLO
	mail-lb0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756778AbcB0XDF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Feb 2016 18:03:05 -0500
Received: by mail-lb0-f170.google.com with SMTP id bc4so63054432lbc.2
        for <netdev@vger.kernel.org>; Sat, 27 Feb 2016 15:03:03 -0800 (PST)
In-Reply-To: <20160226.124645.2123990166666725876.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 26, 2016 at 12:46 PM, David Miller <davem@davemloft.net> wrote:
> From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
> Date: Fri, 26 Feb 2016 12:33:13 -0500
>
>> Right. The simplest, if hacky, fix is to add something along the lines of
>>
>>   static unsigned short netdev_min_hard_header_len(struct net_device *dev)
>>   {
>>       if (unlikely(dev->type ==ARPHDR_AX25))
>>         return AX25_KISS_HEADER_LEN;
>>       else
>>         return dev->hard_header_len;
>>   }
>>
>> Depending on how the variable encoding scheme works, a basic min
>> length check may still produce buggy headers that confuse the stack or
>> driver. I need to read up on AX25. If so, then extending header_ops
>> with an optional validate() function is a more generic approach of
>> checking header sanity.
>
> I suspect we will need some kind of header ops for this.

To return the device type minimum length or to do full header validation?

Looking at drivers/net/hamradio, I don't see any driver output paths
interpreting the header fields, in which case the first is sufficient.
A minimum U/S frame is

  AX25_KISS_HEADER_LEN + 2* AX25_ADDR_LEN + 3 (control + FCS) ==
  AX25_KISS_HEADER_LEN + AX25_HEADER_LEN

Heikki, you gave this number + 3. Where does that constant come from?

More thorough validation of the header contents is not necessarily
hard. The following validates the address, including optional
repeaters.

  static bool ax25_validate_hard_header(const char *ll_header,
                                       unsigned short len)
  {
         ax25_digi digi;

         return !ax25_addr_parse(ll_header, len, NULL, NULL, &digi, NULL, NULL);
  }

The major drawback of full validation from the point of fixing the
original bug that it requires the header already having been copied to
the kernel. The ll_header_truncated check is currently performed
before allocation + copy, based solely on len. So this might become a
relatively complex patch that is not easy to backport to stable
branches.

I can send simple minimal length validation patch to net to solve the
reported bug. Then optionally follow up with a header_ops->validate()
extension in net-next, if there is value in that.
