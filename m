From: Alexey Charkov <alchark@gmail.com>
Subject: Re: [PATCH] net: via-rhine: fix compiler warning
Date: Wed, 30 Apr 2014 13:22:51 +0400
Message-ID: <CABjd4YzRTPcy1nbhywuNLb0pz4gPVjhzegZJTc_g+_SVc1XJvw@mail.gmail.com>
References: <1398792971-10379-1-git-send-email-mq@suse.cz>
	<063D6719AE5E284EB5DD2968C1650D6D0F702C5F@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jan Moskyto Matejka <mq@suse.cz>, Roger Luethi <rl@hellgate.ch>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: David Laight <David.Laight@aculab.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D0F702C5F@AcuExch.aculab.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2014-04-30 12:49 GMT+04:00 David Laight <David.Laight@aculab.com>:
> From: Jan Moskyto Matejka
>> Fixed different size cast warning:
>>
>>       drivers/net/ethernet/via/via-rhine.c: In function rhine_init_one_platform:
>>       drivers/net/ethernet/via/via-rhine.c:1132:13: warning: cast from pointer to integer of different
>> size [-Wpointer-to-int-cast]
>>         revision = (u32)match->data;
>>                    ^
>>
>> That code was added in commit 2d283862dc62daead9db0dc89cd0d0351e91f765
>> ("net: via-rhine: add OF bus binding").
> ...
>> diff --git a/drivers/net/ethernet/via/via-rhine.c b/drivers/net/ethernet/via/via-rhine.c
>> index 4fa9201..76d18e0 100644
>> --- a/drivers/net/ethernet/via/via-rhine.c
>> +++ b/drivers/net/ethernet/via/via-rhine.c
>> @@ -288,7 +288,7 @@ MODULE_DEVICE_TABLE(pci, rhine_pci_tbl);
>>   * (for quirks etc.)
>>   */
>>  static struct of_device_id rhine_of_tbl[] = {
>> -     { .compatible = "via,vt8500-rhine", .data = (void *)0x84 },
>> +     { .compatible = "via,vt8500-rhine", .data = (u32 []) { 0x84 } },
>>       { }     /* terminate list */
>>  };
>>  MODULE_DEVICE_TABLE(of, rhine_of_tbl);
>> @@ -1129,7 +1129,7 @@ static int rhine_init_one_platform(struct platform_device *pdev)
>>       if (!irq)
>>               return -EINVAL;
>>
>> -     revision = (u32)match->data;
>> +     revision = *((u32 *) match->data);
>>       if (!revision)
>>               return -EINVAL;
>
> Both those casts look horrid.
> I'm not entirely convinced that the first is valid C - It would have to be
> something specific to C99 initialisers.
> Casts like *(u32 *)foo are also likely to be bugs (esp. on BE systems)
> so themselves start ringing alarm bells.
>
> So why not just:
>         revision = (unsigned long)match->data;
> and add a comment that the 0x84 is the revision - #define ??

There is no particular reason why it should be u32 now - this is a
leftover from the previous iteration of code where revision was a
separate property in DT (sized u32). It actually mirrors the
respective field in struct pci_dev, which is u8 - don't see any issue
defining it as unsigned long (and also changing the definition in
struct rhine_private).

The comment that it's the revision is right above the match table (cut
off in the patch) :)

Jan, would you prefer to adjust your patch, or shall I send another
one to change rp->revision and friends to unsigned long?

Thanks a lot,
Alexey
