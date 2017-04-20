From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: __sk_buff.data_end
Date: Thu, 20 Apr 2017 02:01:49 +0200
Message-ID: <58F7FA6D.5030000@iogearbox.net>
References: <1492637460.22185.6.camel@sipsolutions.net>  (sfid-20170419_233114_060429_CAFE85B8) <1492640459.22185.7.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>,
        Alexei Starovoitov <ast@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:56117 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S968831AbdDTABw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Apr 2017 20:01:52 -0400
In-Reply-To: <1492640459.22185.7.camel@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/20/2017 12:20 AM, Johannes Berg wrote:
> On Wed, 2017-04-19 at 23:31 +0200, Johannes Berg wrote:
>> Hi Alexei, Daniel,
>>
>> I'm looking at adding the __wifi_sk_buff I talked about, and I notice
>> that it uses CB space to store data_end. Unfortunately, in a lot of
>> cases, we don't have any CB space to spare in wifi.
>
> I guess I can work around this, would this seem reasonable?
>
>   struct bpf_skb_data_end {
>          struct qdisc_skb_cb qdisc_cb;
> -       void *data_end;
> +       /*
> +        * The alignment here is for mac80211, since that doesn't use
> +        * a pointer but a u64 value and needs to save/restore that
> +        * across running its BPF programs.
> +        */
> +       void *data_end __aligned(sizeof(u64));
>   };

Yeah, should work as well for the 32 bit archs, on 64 bit we
have this effectively already:

struct bpf_skb_data_end {
         struct qdisc_skb_cb        qdisc_cb;             /*     0    28 */

         /* XXX 4 bytes hole, try to pack */

         void *                     data_end;             /*    32     8 */

         /* size: 40, cachelines: 1, members: 2 */
         /* sum members: 36, holes: 1, sum holes: 4 */
         /* last cacheline: 40 bytes */
};

Can you elaborate on why this works for mac80211? It uses cb
only up to that point from where you invoke the prog?
