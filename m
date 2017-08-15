From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH net-next V2 3/3] tap: XDP support
Date: Tue, 15 Aug 2017 12:55:37 +0800
Message-ID: <3bc5f71d-5a2c-5b59-037c-b0c2365bbe93@redhat.com>
References: <1502451678-17358-1-git-send-email-jasowang@redhat.com>
 <1502451678-17358-4-git-send-email-jasowang@redhat.com>
 <599162CA.4080504@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: davem@davemloft.net, mst@redhat.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, kubakici@wp.pl
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <599162CA.4080504@iogearbox.net>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 2017年08月14日 16:43, Daniel Borkmann wrote:
> On 08/11/2017 01:41 PM, Jason Wang wrote:
>> This patch tries to implement XDP for tun. The implementation was
>> split into two parts:
> [...]
>> @@ -1402,6 +1521,22 @@ static ssize_t tun_get_user(struct tun_struct 
>> *tun, struct tun_file *tfile,
>>       skb_reset_network_header(skb);
>>       skb_probe_transport_header(skb, 0);
>>
>> +    if (generic_xdp) {
>> +        struct bpf_prog *xdp_prog;
>> +        int ret;
>> +
>> +        rcu_read_lock();
>> +        xdp_prog = rcu_dereference(tun->xdp_prog);
>
> The name generic_xdp is a bit confusing in this context given this
> is 'native' XDP, perhaps above if (generic_xdp) should have a comment
> explaining semantics for tun and how it relates to actual generic xdp
> that sits at dev->xdp_prog, and gets run from netif_rx_ni(). Or just
> name the bool xdp_handle_gso with a comment that we let the generic
> XDP infrastructure deal with non-linear skbs instead of having to
> re-implement the do_xdp_generic() internals, plus a statement that
> the actual generic XDP comes a bit later in the path. That would at
> least make it more obvious to read, imho.

Ok, since non gso packet (e.g jumbo packet) may go this way too, 
something like "xdp_handle_skb" is better. Will send a patch.

Thanks

>
>> +        if (xdp_prog) {
>> +            ret = do_xdp_generic(xdp_prog, skb);
>> +            if (ret != XDP_PASS) {
>> +                rcu_read_unlock();
>> +                return total_len;
>> +            }
>> +        }
>> +        rcu_read_unlock();
>> +    }
>> +
>>       rxhash = __skb_get_hash_symmetric(skb);
>>   #ifndef CONFIG_4KSTACKS
>>       tun_rx_batched(tun, tfile, skb, more);
>>
>
