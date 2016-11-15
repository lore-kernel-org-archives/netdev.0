From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH v3] ip6_output: ensure flow saddr actually
 belongs to device
Date: Tue, 15 Nov 2016 08:26:42 -0700
Message-ID: <4285324b-c396-dfc1-caad-c961a6564e94@cumulusnetworks.com>
References: <27cccef1-06d9-74b3-5b8a-912850119a76@cumulusnetworks.com>
 <20161113232813.28926-1-Jason@zx2c4.com>
 <1479141867.3723362.787321689.4A3DCFD6@webmail.messagingengine.com>
 <fd1c804d-3e44-0321-8a3e-67d6ff7357fa@cumulusnetworks.com>
 <7d8c0210-9132-c755-9053-6ec19409e343@stressinduktion.org>
 <c75290bd-7ea2-0bf8-7ac0-fc5a3c81e312@cumulusnetworks.com>
 <7779da88-08dc-0adb-42dd-8e00502693df@stressinduktion.org>
 <0214eaf8-70c6-5a37-cddd-faa1c4268871@cumulusnetworks.com>
 <1479148385.3747043.787432273.5FCC2F4F@webmail.messagingengine.com>
 <CAHmME9ppx01YR9Db1oPpm6FJ+BmpqSxvjQ2S+GT0DXO09_M4oQ@mail.gmail.com>
 <7543fa0f-a053-8387-1862-d78ffadba688@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>,
 WireGuard mailing list <wireguard@lists.zx2c4.com>,
 YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>,
 "Jason A. Donenfeld" <Jason@zx2c4.com>
Return-path: <wireguard-bounces@lists.zx2c4.com>
In-Reply-To: <7543fa0f-a053-8387-1862-d78ffadba688@stressinduktion.org>
List-Unsubscribe: <http://lists.zx2c4.com/mailman/options/wireguard>,
 <mailto:wireguard-request@lists.zx2c4.com?subject=unsubscribe>
List-Archive: <http://lists.zx2c4.com/pipermail/wireguard/>
List-Post: <mailto:wireguard@lists.zx2c4.com>
List-Help: <mailto:wireguard-request@lists.zx2c4.com?subject=help>
List-Subscribe: <http://lists.zx2c4.com/mailman/listinfo/wireguard>,
 <mailto:wireguard-request@lists.zx2c4.com?subject=subscribe>
Errors-To: wireguard-bounces@lists.zx2c4.com
Sender: "WireGuard" <wireguard-bounces@lists.zx2c4.com>
List-Id: netdev.vger.kernel.org

On 11/15/16 7:45 AM, Hannes Frederic Sowa wrote:

>> @@ -1012,6 +1013,16 @@ static int ip6_dst_lookup_tail(struct net *net,
>> const struct sock *sk,
>>          }
>>  #endif
>>
>> +        addr_type = ipv6_addr_type(&fl6->saddr);
>> +        if (addr_type == IPv6_ADDR_ANY)
>> +                return 0;
>> +
>> +        err = -EINVAL;
>> +        bind_to_dev = __ipv6_addr_src_scope(addr_type) <=
>> IPV6_ADDR_SCOPE_LINKLOCAL;
>> +        if (!ipv6_chk_addr(net, &fl6->saddr, bind_to_dev ?
>> (*dst)->dev : NULL, 0) &&
>> +            !ipv6_chk_acast_addr_src(net, (*dst)->dev, &fl6->saddr))
>> +                goto out_err_release;
>> +
>>          return 0;
>>
>>  out_err_release:
>>
> 
> We should not use (*dst)->dev, as this is the resulting device after the
> lookup and not necessarily corresponds to the device the user asked for.

To be consistent with IPv4 the saddr check is done before the lookup and dst and flow oif should not be used. Handling LL addresses are trickier and perhaps this is not the right place to enforce that check since it requires a specific device which is only really known after lookup. Why not add the if saddr is LL verification as part of the route selection? e.g, add something like rt6_device_match to ip6_pol_route (the device match call is only used for ip6_pol_route_lookup and not ip6_pol_route - why is that?).
