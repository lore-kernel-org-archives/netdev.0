From: Amir Vadai <amirva@gmail.com>
Subject: Re: [PATCH iproute2 V2 1/2] tc/cls_flower: Classify packet in ip tunnels
Date: Wed, 30 Nov 2016 09:42:25 +0200
Message-ID: <CAML6477eC2p2zw9at0nX1jT+xQ4jvXup6UnfM4x6AaGXRsXUdw@mail.gmail.com>
References: <20161128125136.3393-1-amir@vadai.me> <20161128125136.3393-2-amir@vadai.me>
 <20161129192658.5a4c3e2c@samsung9.wavecable.com> <20161130071753.GA1366@office.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Netdev List <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Jiri Benc <jbenc@redhat.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Hadar Har-Zion <hadarh@mellanox.com>,
        Roi Dayan <roid@mellanox.com>
To: Stephen Hemminger <stephen@networkplumber.org>,
        Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:34474 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754270AbcK3Hm1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2016 02:42:27 -0500
Received: by mail-wm0-f66.google.com with SMTP id g23so28052072wme.1
        for <netdev@vger.kernel.org>; Tue, 29 Nov 2016 23:42:27 -0800 (PST)
In-Reply-To: <20161130071753.GA1366@office.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 30, 2016 at 9:17 AM, Amir Vadai <amir@vadai.me> wrote:
> On Tue, Nov 29, 2016 at 07:26:58PM -0800, Stephen Hemminger wrote:
(Sending again since I just discovered that Google Inbox is adding an
HTML part...)

>> The overall design is fine, just a couple nits with the code.
>>
>> > diff --git a/tc/f_flower.c b/tc/f_flower.c
>> > index 2d31d1aa832d..1cf0750b5b83 100644
>> > --- a/tc/f_flower.c
>> > +++ b/tc/f_flower.c
>>
>> >
>> > +static int flower_parse_key_id(char *str, int type, struct nlmsghdr *n)
>>
>> str is not modified, therefore use: const char *str
> ack
>
>>
>> > +{
>> > +   int ret;
>> > +   __be32 key_id;
>> > +
>> > +   ret = get_be32(&key_id, str, 10);
>> > +   if (ret)
>> > +           return -1;
>>
>> Traditionally netlink attributes are in host order, why was flower
>> chosen to be different?
> I don't know, maybe Jiri (cc'ed) can explain, but it is all over the
> flower code.
Now the right Jiri (Pirko) is CC'ed

>
>>
>> > +
>> > +   addattr32(n, MAX_MSG, type, key_id);
>> > +
>> > +   return 0;
>>
>>
>> Why lose the return value here?  Why not:
>>
>>       ret = get_be32(&key_id, str, 10);
>>       if (!ret)
>>               addattr32(n, MAX_MSG, type, key_id);
> The get_*() function can return only -1 or 0. But you are right, and it
> is better the way you suggested.  Changing accordingly in V3.
>
>>
>> > +}
>> > +
>> >  static int flower_parse_opt(struct filter_util *qu, char *handle,
>> >                         int argc, char **argv, struct nlmsghdr *n)
>> >  {
>> > @@ -339,6 +359,38 @@ static int flower_parse_opt(struct filter_util *qu, char *handle,
>> >                             fprintf(stderr, "Illegal \"src_port\"\n");
>> >                             return -1;
>> >                     }
>> > +           } else if (matches(*argv, "enc_dst_ip") == 0) {
>> > +                   NEXT_ARG();
>> > +                   ret = flower_parse_ip_addr(*argv, 0,
>> > +                                              TCA_FLOWER_KEY_ENC_IPV4_DST,
>> > +                                              TCA_FLOWER_KEY_ENC_IPV4_DST_MASK,
>> > +                                              TCA_FLOWER_KEY_ENC_IPV6_DST,
>> > +                                              TCA_FLOWER_KEY_ENC_IPV6_DST_MASK,
>> > +                                              n);
>> > +                   if (ret < 0) {
>> > +                           fprintf(stderr, "Illegal \"enc_dst_ip\"\n");
>> > +                           return -1;
>> > +                   }
>> > +           } else if (matches(*argv, "enc_src_ip") == 0) {
>> > +                   NEXT_ARG();
>> > +                   ret = flower_parse_ip_addr(*argv, 0,
>> > +                                              TCA_FLOWER_KEY_ENC_IPV4_SRC,
>> > +                                              TCA_FLOWER_KEY_ENC_IPV4_SRC_MASK,
>> > +                                              TCA_FLOWER_KEY_ENC_IPV6_SRC,
>> > +                                              TCA_FLOWER_KEY_ENC_IPV6_SRC_MASK,
>> > +                                              n);
>> > +                   if (ret < 0) {
>> > +                           fprintf(stderr, "Illegal \"enc_src_ip\"\n");
>> > +                           return -1;
>> > +                   }
>> > +           } else if (matches(*argv, "enc_key_id") == 0) {
>> > +                   NEXT_ARG();
>> > +                   ret = flower_parse_key_id(*argv,
>> > +                                             TCA_FLOWER_KEY_ENC_KEY_ID, n);
>> > +                   if (ret < 0) {
>> > +                           fprintf(stderr, "Illegal \"enc_key_id\"\n");
>> > +                           return -1;
>> > +                   }
>> >             } else if (matches(*argv, "action") == 0) {
>> >                     NEXT_ARG();
>> >                     ret = parse_action(&argc, &argv, TCA_FLOWER_ACT, n);
>> > @@ -509,6 +561,14 @@ static void flower_print_port(FILE *f, char *name, __u8 ip_proto,
>> >     fprintf(f, "\n  %s %d", name, ntohs(rta_getattr_u16(attr)));
>> >  }
>> >
>> > +static void flower_print_key_id(FILE *f, char *name,
>> > +                           struct rtattr *attr)
>>
>> const char *name?
> ack
>
>>
>>
>> > +{
>> > +   if (!attr)
>> > +           return;
>> > +   fprintf(f, "\n  %s %d", name, ntohl(rta_getattr_u32(attr)));
>> > +}
>> > +
>>
>> Why short circuit, just change the order:
>>
>>       if (attr)
>>               fprintf(f, "\n  %s %s", name, ntohl(rta_getattr_u32(attr));
>>
>> You might also want to introduce rta_getattr_be32()
> ack
>
>>
>> Please change, retest and resubmit both patches.
> ack
>
> Thanks for reviewing,
> Amir
