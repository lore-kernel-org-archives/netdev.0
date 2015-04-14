From: Amir Vadai <amirv@mellanox.com>
Subject: Re: [PATCH ethtool 5/5] ethtool: Support for configurable RSS hash function
Date: Tue, 14 Apr 2015 18:37:43 +0300
Message-ID: <CAPcc5Pj79rtHgGgfi1iezYK1arjFrsaAfLoMDwAjncPMR_LHvg@mail.gmail.com>
References: <1422193883-30504-1-git-send-email-amirv@mellanox.com>
	<1422193883-30504-6-git-send-email-amirv@mellanox.com>
	<1428202547.11260.160.camel@decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Amir Vadai <amirv@mellanox.com>, netdev <netdev@vger.kernel.org>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Eyal Perry <eyalpe@mellanox.com>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f49.google.com ([209.85.215.49]:35611 "EHLO
	mail-la0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753922AbbDNPho (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Apr 2015 11:37:44 -0400
Received: by labbd9 with SMTP id bd9so11299336lab.2
        for <netdev@vger.kernel.org>; Tue, 14 Apr 2015 08:37:43 -0700 (PDT)
In-Reply-To: <1428202547.11260.160.camel@decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Apr 5, 2015 at 5:55 AM, Ben Hutchings <ben@decadent.org.uk> wrote:
> On Sun, 2015-01-25 at 15:51 +0200, Amir Vadai wrote:
>> From: Eyal Perry <eyalpe@mellanox.com>
>>
>> This ethtool patch adds support to set and get the current RSS hash
>> function for the device through through the new hfunc mask field in the
>> ethtool_rxfh struct. Kernel supported hash function names are queried
>> with ETHTOOL_GSTRINGS - each string is corresponding with a bit in hfunc
>> mask according to its index in the string-set.
>>
>> Signed-off-by: Eyal Perry <eyalpe@mellanox.com>
>> Signed-off-by: Amir Vadai <amirv@mellanox.com>
>> ---
>>  ethtool.8.in |  7 +++++++
>>  ethtool.c    | 56 +++++++++++++++++++++++++++++++++++++++++++++++++++-----
>>  2 files changed, 58 insertions(+), 5 deletions(-)
>>
>> diff --git a/ethtool.8.in b/ethtool.8.in
>> index ae56293..bdc77e0 100644
>> --- a/ethtool.8.in
>> +++ b/ethtool.8.in
>> @@ -297,6 +297,8 @@ ethtool \- query or control network driver and hardware settings
>>  .BI weight\  W0
>>  .IR W1
>>  .RB ...\ ]
>> +.RB [ hfunc
>> +.IR FUNC ]
>>  .HP
>>  .B ethtool \-f|\-\-flash
>>  .I devname file
>> @@ -796,6 +798,11 @@ Sets RSS hash key of the specified network device. RSS hash key should be of dev
>>  Hash key format must be in xx:yy:zz:aa:bb:cc format meaning both the nibbles of a byte should be mentioned
>>  even if a nibble is zero.
>>  .TP
>> +.BI hfunc
>> +Sets RSS hash function of the specified network device. Requested hash function
>> +should be supported by the kernel and the device.
>
> I think the second sentence is unneeded - obviously requesting an
> unsupported hash function will fail.
Will be fixed for V1

>
>>  List of RSS hash functions
>
> 'A list of ...'
Ack

>
>> +which kernel supports is shown as a part of the --show-rxfh comand output.
>
> '... which the device supports ...' (since this depends on the hardware
> and driver as well as the kernel).
Ack

>
>> +.TP
>>  .BI equal\  N
>>  Sets the receive flow hash indirection table to spread flows evenly
>>  between the first \fIN\fR receive queues.
>> diff --git a/ethtool.c b/ethtool.c
>> index c2f4164..c584333 100644
>> --- a/ethtool.c
>> +++ b/ethtool.c
>> @@ -3176,10 +3176,11 @@ static int do_grxfh(struct cmd_context *ctx)
>>  {
>>       struct ethtool_rxfh rss_head = {0};
>>       struct ethtool_rxnfc ring_count;
>> +     struct ethtool_gstrings *hfuncs;
>>       struct ethtool_rxfh *rss;
>>       u32 i, indir_bytes;
>>       char *hkey;
>> -     int err;
>> +     int err, cur_len, max_len = 0;
>>
>>       ring_count.cmd = ETHTOOL_GRXRINGS;
>>       err = send_ioctl(ctx, &ring_count);
>> @@ -3231,6 +3232,23 @@ static int do_grxfh(struct cmd_context *ctx)
>>                       printf("%02x:", (u8) hkey[i]);
>>       }
>>
>> +     printf("RSS hash function:\n");
>> +     if (!rss->hfunc) {
>> +             printf("    Operation not supported\n");
>> +             goto out;
>> +     }
>> +     hfuncs = get_stringset(ctx, ETH_SS_RSS_HASH_FUNCS, 0, 1);
>> +     for (i = 0; i < hfuncs->len; i++) {
>> +             cur_len = strlen((const char *)hfuncs->data +
>> +                              i * ETH_GSTRING_LEN);
>> +             if (cur_len > max_len)
>> +                     max_len = cur_len;
>> +     }
>> +     for (i = 0; i < hfuncs->len; i++)
>> +             printf("    %-*s: %s\n", max_len,
>> +                    (const char *)hfuncs->data + i * ETH_GSTRING_LEN,
>> +                    (rss->hfunc & (1 << i)) ? "on" : "off");
>
> I'm puzzled by this.  Do you remember why the hash functions were given
> flag numbers rather than serial numbers?  Would it ever make sense to
> have multiple hash functions enabled?
I don't think it will make sense to have multiple hash function
enabled at the same time, but using flag numbers could be useful for
setting an attribute in addition to the hash function.
Currently there is no such use case that I can think of.

>
> If only one hash function can be enabled (which seems to be true at
> least for current drivers) then this only needs to print the one hash
> function that is enabled.  (But then, the user needs to be able to list
> the available hash functions somehow.)
>
> If multiple hash functions can be enabled, then we should support that
> in do_srxfh(), don't we?
Right, will fix it for V1

>
>> +out:
>>       free(rss);
>>       return 0;
>>  }
> [...]
>> @@ -3410,6 +3454,7 @@ static int do_srxfh(struct cmd_context *ctx)
>>       rss->cmd = ETHTOOL_SRSSH;
>>       rss->indir_size = rss_head.indir_size;
>>       rss->key_size = rss_head.key_size;
>> +     rss->hfunc = req_hfunc ? req_hfunc : 0;
>
> That's a complicated way to write '= req_hfunc;'.
Will fix in V1.

Thanks,
Amir
>
> Ben.
>
>>       if (fill_indir_table(&rss->indir_size, rss->rss_config, rxfhindir_equal,
>>                            rxfhindir_weight, num_weights)) {
>> @@ -4119,7 +4164,8 @@ static const struct option {
>>       { "-X|--set-rxfh-indir|--rxfh", 1, do_srxfh,
>>         "Set Rx flow hash indirection and/or hash key",
>>         "             [ equal N | weight W0 W1 ... ]\n"
>> -       "             [ hkey %x:%x:%x:%x:%x:.... ]\n" },
>> +       "             [ hkey %x:%x:%x:%x:%x:.... ]\n"
>> +       "             [ hfunc FUNC ]\n"},
>>       { "-f|--flash", 1, do_flash,
>>         "Flash firmware image from the specified file to a region on the device",
>>         "               FILENAME [ REGION-NUMBER-TO-FLASH ]\n" },
>
> --
> Ben Hutchings
> Quantity is no substitute for quality, but it's the only one we've got.
