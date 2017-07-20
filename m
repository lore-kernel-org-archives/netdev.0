From: Marcin Wojtas <mw@semihalf.com>
Subject: Re: [PATCH 1/2] net: mvneta: remove bogus use of
Date: Thu, 20 Jul 2017 18:01:04 +0200
Message-ID: <CAPv3WKdv4tO7p07w0Ynczq66z+Jq13wbYEwriNY19PWgTjdieQ@mail.gmail.com>
References: <20170720142711.12847-1-robh@kernel.org> <8760en5es2.fsf@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
        Gregory CLEMENT <gregory.clement@free-electrons.com>,
        netdev@vger.kernel.org,
        "devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
        Frank Rowand <frowand.list@gmail.com>
To: Rob Herring <robh@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f172.google.com ([209.85.223.172]:34685 "EHLO
        mail-io0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934497AbdGTQBF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Jul 2017 12:01:05 -0400
Received: by mail-io0-f172.google.com with SMTP id l7so13427700iof.1
        for <netdev@vger.kernel.org>; Thu, 20 Jul 2017 09:01:05 -0700 (PDT)
In-Reply-To: <8760en5es2.fsf@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Rob,

I somehow missed this patch.

2017-07-20 17:06 GMT+02:00 Gregory CLEMENT <gregory.clement@free-electrons.com>:
> Hi Rob,
>
>  On jeu., juil. 20 2017, Rob Herring <robh@kernel.org> wrote:
>
> (Adding Marcin in CC who wrote this part of code)
>
>> Nothing sets ever sets data, so it is always NULL. Remove it as this is
>> the only user of data ptr in the whole kernel, and it is going to be
>> removed from struct device_node.
>
> Actually the use of device_node.data ptr is not bogus and it is set in
> mvneta_bm_probe:
> http://elixir.free-electrons.com/linux/latest/source/drivers/net/ethernet/marvell/mvneta_bm.c#L433
>
> Your patch will break the BM support on this driver. So if you need to
> remove this data ptr, then you have to offer an alternative for it.

Exactly, this breaks NETA operation with BM block. The data is set in:

dn->data = priv;
platform_set_drvdata(pdev, priv);

At the time I couldn't have found out a nicer solution to make work
two different HW blocks (network controller and buffer manager). There
was once a patchset enabling calling another driver's probe basing on
the phandle and of_node information, but after it reached ~v7 it
eventually didn't make it to the tree. Do you any way for solving such
dependencies, if you really want to get rid of this field?

Best regards,
Marcin

>
> Thanks,
>
> Gregory
>
>>
>> Cc: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
>> Signed-off-by: Rob Herring <robh@kernel.org>
>> ---
>> Probably there's a better fix here to actually enable the h/w buffer
>> manager.
>>
>> I intend to take this thru the DT tree as patch 2 is dependent on this.
>>
>> Rob
>>
>>  drivers/net/ethernet/marvell/mvneta.c | 4 ++--
>>  1 file changed, 2 insertions(+), 2 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
>> index 0aab74c2a209..5624f4b49f9d 100644
>> --- a/drivers/net/ethernet/marvell/mvneta.c
>> +++ b/drivers/net/ethernet/marvell/mvneta.c
>> @@ -4296,8 +4296,8 @@ static int mvneta_probe(struct platform_device *pdev)
>>
>>       /* Obtain access to BM resources if enabled and already initialized */
>>       bm_node = of_parse_phandle(dn, "buffer-manager", 0);
>> -     if (bm_node && bm_node->data) {
>> -             pp->bm_priv = bm_node->data;
>> +     if (bm_node) {
>> +             pp->bm_priv = NULL;
>>               err = mvneta_bm_port_init(pdev, pp);
>>               if (err < 0) {
>>                       dev_info(&pdev->dev, "use SW buffer management\n");
>> --
>> 2.11.0
>>
>
> --
> Gregory Clement, Free Electrons
> Kernel, drivers, real-time and embedded Linux
> development, consulting, training and support.
> http://free-electrons.com
