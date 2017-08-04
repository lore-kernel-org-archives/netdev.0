From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [RFC PATCH 4/6] net: sockmap with sk redirect support
Date: Thu, 03 Aug 2017 21:49:58 -0700
Message-ID: <5983FCF6.7050103@gmail.com>
References: <20170803232443.12107.24752.stgit@john-Precision-Tower-5810> <20170803233756.12107.54982.stgit@john-Precision-Tower-5810> <CALx6S36fmiyFNTif2B6X91wPXWEb1W3pk5=N0JTMD0T9ZoL5fw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Alexei Starovoitov <ast@fb.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:35181 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750899AbdHDEuL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 4 Aug 2017 00:50:11 -0400
Received: by mail-pg0-f68.google.com with SMTP id l64so714515pge.2
        for <netdev@vger.kernel.org>; Thu, 03 Aug 2017 21:50:11 -0700 (PDT)
In-Reply-To: <CALx6S36fmiyFNTif2B6X91wPXWEb1W3pk5=N0JTMD0T9ZoL5fw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/03/2017 09:22 PM, Tom Herbert wrote:
> On Thu, Aug 3, 2017 at 4:37 PM, John Fastabend <john.fastabend@gmail.com> wrote:
>> Recently we added a new map type called dev map used to forward XDP
>> packets between ports (6093ec2dc313). This patches introduces a
>> similar notion for sockets.
>>
>> A sockmap allows users to add participating sockets to a map. When
>> sockets are added to the map enough context is stored with the
>> map entry to use the entry with a new helper
>>
>>   bpf_sk_redirect_map(map, key, flags)
>>
>> This helper (analogous to bpf_redirect_map in XDP) is given the map
>> and an entry in the map. When called from a sockmap program, discussed
>> below, the skb will be sent on the socket using skb_send_sock().
>>
>> With the above we need a bpf program to call the helper from that will
>> then implement the send logic. The initial site implemented in this
>> series is the recv_sock hook. For this to work we implemented a map
>> attach command to add attributes to a map. In sockmap we add two
>> programs a parse program and a verdict program. The parse program
>> uses strparser to build messages and pass them to the verdict program.
>> The parse program usese normal strparser semantics. The verdict
>> program is of type SOCKET_FILTER.
>>
>> The verdict program returns a verdict BPF_OK, BPF_DROP, BPF_REDIRECT.
>> When BPF_REDIRECT is returned, expected when bpf program uses
>> bpf_sk_redirect_map(), the sockmap logic will consult per cpu variables
>> set by the helper routine and pull the sock entry out of the sock map.
>> This pattern follows the existing redirect logic in cls and xdp
>> programs.
>>
> Hi John,
> 
> I'm a bit confused. If the verdict program bpf_mux then? I don't see
> any use of BPF_OK,DROP, or REDIRECT. I assume I'm missing something.
> 
> Tom

Ah so what I coded and what I wrote don't align perfectly here. The
verdict program _is_ bpf_mux as you guessed. I should rename the code
to use bpf_verdict (or come up with a better name). Calling it bpf_mux
was a hold out from a very specific example program I wrote up.

Then BPF_OK_DROP and BPF_REDIRECT still need to be included in below.

[...]

>> +
>> +static struct smap_psock *smap_peers_get(struct smap_psock *psock,
>> +                                            struct sk_buff *skb)
>> +{
>> +       struct sock *sock;
>> +       int rc;
>> +
>> +       rc = smap_mux_func(psock, skb);
>> +       if (unlikely(rc < 0))
>> +               return NULL;
>> +

replacing the above 3 lines with the following should align the commit
message and code,

	   rc = smap_mux_func(psock, skb);
	   if (rc != BPF_REDIRECT)
		return NULL;

>> +       sock = do_sk_redirect_map();
>> +       if (unlikely(!sock))
>> +               return NULL;
>> +
>> +       return smap_psock_sk(sock);
>> +}
>> +

And then in uapi/linux/bpf.h

enum {
	BPF_OK_DROP,
	BPF_REDIRECT,
}

Thanks,
John
