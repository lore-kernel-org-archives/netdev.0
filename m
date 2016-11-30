From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH net-next v3 3/4] bpf: BPF for lightweight tunnel
 infrastructure
Date: Tue, 29 Nov 2016 18:52:36 -0800
Message-ID: <583E3EF4.7030107@gmail.com>
References: <cover.1480424542.git.tgraf@suug.ch>
 <7cc79a82e49996a9ebbff861af471018fdf118fb.1480424542.git.tgraf@suug.ch>
 <20161130001504.GA28238@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, daniel@iogearbox.net,
        tom@herbertland.com, roopa@cumulusnetworks.com,
        hannes@stressinduktion.org
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:33933 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751913AbcK3Cwv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2016 21:52:51 -0500
Received: by mail-pg0-f67.google.com with SMTP id e9so18122457pgc.1
        for <netdev@vger.kernel.org>; Tue, 29 Nov 2016 18:52:50 -0800 (PST)
In-Reply-To: <20161130001504.GA28238@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-11-29 04:15 PM, Alexei Starovoitov wrote:
> On Tue, Nov 29, 2016 at 02:21:22PM +0100, Thomas Graf wrote:
>> Registers new BPF program types which correspond to the LWT hooks:
>>   - BPF_PROG_TYPE_LWT_IN   => dst_input()
>>   - BPF_PROG_TYPE_LWT_OUT  => dst_output()
>>   - BPF_PROG_TYPE_LWT_XMIT => lwtunnel_xmit()
>>
>> The separate program types are required to differentiate between the
>> capabilities each LWT hook allows:
>>
>>  * Programs attached to dst_input() or dst_output() are restricted and
>>    may only read the data of an skb. This prevent modification and
>>    possible invalidation of already validated packet headers on receive
>>    and the construction of illegal headers while the IP headers are
>>    still being assembled.
>>
>>  * Programs attached to lwtunnel_xmit() are allowed to modify packet
>>    content as well as prepending an L2 header via a newly introduced
>>    helper bpf_skb_push(). This is safe as lwtunnel_xmit() is invoked
>>    after the IP header has been assembled completely.
>>
>> All BPF programs receive an skb with L3 headers attached and may return
>> one of the following error codes:
>>
>>  BPF_OK - Continue routing as per nexthop
>>  BPF_DROP - Drop skb and return EPERM
>>  BPF_REDIRECT - Redirect skb to device as per redirect() helper.
>>                 (Only valid in lwtunnel_xmit() context)
>>
>> The return codes are binary compatible with their TC_ACT_
>> relatives to ease compatibility.
>>
>> Signed-off-by: Thomas Graf <tgraf@suug.ch>
> ...
>> +#define LWT_BPF_MAX_HEADROOM 128
> 
> why 128?
> btw I'm thinking for XDP to use 256, so metadata can be stored in there.
> 

hopefully not too off-topic but for XDP I would like to see this get
passed down with the program. It would be more generic and drivers could
configure the headroom on demand and more importantly verify that a
program pushing data is not going to fail at runtime.

.John
