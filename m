From: Tariq Toukan <ttoukan.linux@gmail.com>
Subject: Re: [PATCH v8 06/11] net/mlx4_en: add page recycle to prepare rx ring
 for tx support
Date: Wed, 13 Jul 2016 10:17:26 +0300
Message-ID: <3d0c7f78-0647-e927-94dd-76cbe4ddcb28@gmail.com>
References: <1468309894-26258-1-git-send-email-bblanco@plumgrid.com>
 <1468309894-26258-7-git-send-email-bblanco@plumgrid.com>
 <20160712.141832.634796503160544753.davem@davemloft.net>
 <20160713005424.GB13865@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com,
	saeedm@dev.mellanox.co.il, kafai@fb.com, brouer@redhat.com,
	as754m@att.com, alexei.starovoitov@gmail.com, gerlitz.or@gmail.com,
	john.fastabend@gmail.com, hannes@stressinduktion.org,
	tgraf@suug.ch, tom@herbertland.com, daniel@iogearbox.net
To: Brenden Blanco <bblanco@plumgrid.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f44.google.com ([209.85.215.44]:36388 "EHLO
	mail-lf0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751919AbcGMHRf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jul 2016 03:17:35 -0400
Received: by mail-lf0-f44.google.com with SMTP id q132so31249912lfe.3
        for <netdev@vger.kernel.org>; Wed, 13 Jul 2016 00:17:34 -0700 (PDT)
In-Reply-To: <20160713005424.GB13865@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 13/07/2016 3:54 AM, Brenden Blanco wrote:
> On Tue, Jul 12, 2016 at 02:18:32PM -0700, David Miller wrote:
>> From: Brenden Blanco <bblanco@plumgrid.com>
>> Date: Tue, 12 Jul 2016 00:51:29 -0700
>>
>>> +	mlx4_en_free_resources(priv);
>>> +
>>>   	old_prog = xchg(&priv->prog, prog);
>>>   	if (old_prog)
>>>   		bpf_prog_put(old_prog);
>>>   
>>> -	return 0;
>>> +	err = mlx4_en_alloc_resources(priv);
>>> +	if (err) {
>>> +		en_err(priv, "Failed reallocating port resources\n");
>>> +		goto out;
>>> +	}
>>> +	if (port_up) {
>>> +		err = mlx4_en_start_port(dev);
>>> +		if (err)
>>> +			en_err(priv, "Failed starting port\n");
>> A failed configuration operation should _NEVER_ leave the interface in
>> an inoperative state like these error paths do.
>>
>> You must instead preallocate the necessary resources, and only change
>> the chip's configuration and commit to the new settings once you have
>> successfully allocated those resources.
> I'll see what I can do here.
That's exactly what we're doing in a patchset that will be submitted to 
net very soon (this week).
It fixes/refactors these failure flows just like Dave described, 
something like:

     err = mlx4_en_try_alloc_resources(priv, tmp, &new_prof);
     if (err)
         goto out;

     if (priv->port_up) {
         port_up = 1;
         mlx4_en_stop_port(dev, 1);
     }

     mlx4_en_safe_replace_resources(priv, tmp);

     if (port_up) {
         err = mlx4_en_start_port(dev);
         if (err)
             en_err(priv, "Failed starting port\n");
     }

I suggest you keep your code aligned with current net-next driver, and 
later I will take it and fix it (once merged with net).

Regards,
Tariq
