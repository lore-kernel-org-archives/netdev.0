From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net v3 2/4] net: add rx_nohandler stat counter
Date: Tue, 9 Feb 2016 05:56:28 -0500
Message-ID: <56B9C5DC.4050505@mojatatu.com>
References: <20160208183254.GB4566@redhat.com>
 <20160208113821.0ba26eb0@xeon-e3>
 <1454972260.7627.368.camel@edumazet-glaptop2.roam.corp.google.com>
 <20160209.034023.50018877443465909.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, jarod@redhat.com,
	linux-kernel@vger.kernel.org, edumazet@google.com,
	jiri@mellanox.com, daniel@iogearbox.net, tom@herbertland.com,
	j.vosburgh@gmail.com, vfalico@gmail.com, gospo@cumulusnetworks.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, eric.dumazet@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160209.034023.50018877443465909.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 16-02-09 03:40 AM, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Mon, 08 Feb 2016 14:57:40 -0800
>
>> Whole point of TLV is that it allows us to add new fields at the end of
>> the structures.
>   ...
>> Look at iproute2, you were the one adding in 2004 code to cope with
>> various tcp_info sizes.
>>
>> So 12 years later, you cannot say it does not work anymore.
>
> +1
>

The TLV L should be canonical way to determine length. i.e should be
sufficient to just look at L and understand that content has changed.
But:
Using sizeof could be dangerous unless the data is packed to be
32-bit aligned. Looking INET_DIAG_INFO check for sizeof
there is a small 8 bit hole in tcp_info I think between
these two fields:

----
__u8    tcpi_snd_wscale : 4, tcpi_rcv_wscale : 4;
__u32   tcpi_rto;
---

The kernel will pad to make sure the TLV data is 32-bit aligned.
I am not sure if that will be the same length as sizeof() in all
hardware + compilers... For this case,
it is almost safe to just add a version field - probably in the hole.
Or have a #define to say what the expected length should be. Or add
an 8 bit pad.

In general adding new fields that are non-optional is problematic. i.e
by non-optional i mean always expected to be present.
I think a good test is old kernel with new iproute2. If the new field
is non-optional, it will fail (example iproute2 may try to print a value
that it expects but because old kernel doesnt understand it; it is 
non-existent).

cheers,
jamal
