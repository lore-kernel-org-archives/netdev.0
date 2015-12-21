From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [PATCH net-next V2 3/4] net/mlx5e: Add HW timestamping (TS) support
Date: Mon, 21 Dec 2015 16:35:23 +0200
Message-ID: <CALzJLG-22OjP+CDjJuzm5_oHGRAvG1LZawBfi0UtGEEf5dbviQ@mail.gmail.com>
References: <1450647991-13736-1-git-send-email-saeedm@mellanox.com>
	<1450647991-13736-4-git-send-email-saeedm@mellanox.com>
	<20151221091509.GA2297@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Saeed Mahameed <saeedm@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Majd Dibbiny <majd@mellanox.com>,
	Achiad Shochat <achiad@mellanox.com>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f182.google.com ([209.85.160.182]:34819 "EHLO
	mail-yk0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751213AbbLUOfY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Dec 2015 09:35:24 -0500
Received: by mail-yk0-f182.google.com with SMTP id v6so131878926ykc.2
        for <netdev@vger.kernel.org>; Mon, 21 Dec 2015 06:35:24 -0800 (PST)
In-Reply-To: <20151221091509.GA2297@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 21, 2015 at 11:15 AM, Richard Cochran
<richardcochran@gmail.com> wrote:
> On Sun, Dec 20, 2015 at 11:46:30PM +0200, Saeed Mahameed wrote:
>> +/* Should run once every mlx5e_tstamp->overflow_period */
>> +static void mlx5e_timestamp_overflow(struct work_struct *work)
>> +{
>> +     struct delayed_work *dwork = to_delayed_work(work);
>> +     struct mlx5e_tstamp *tstamp = container_of(dwork, struct mlx5e_tstamp, overflow_work);
>> +     unsigned long flags;
>> +
>> +     write_lock_irqsave(&tstamp->lock, flags);
>> +     timecounter_read(&tstamp->clock);
>> +     if (tstamp->overflow_period)
>> +             schedule_delayed_work(&tstamp->overflow_work, tstamp->overflow_period);
>
> You don't need this test, and the call to schedule_delayed_work can be
> outside of the lock.
>

think of a case where:
CPU1: is just about to call
"schedule_delayed_work(&tstamp->overflow_work,
tstamp->overflow_period);"
CPU2: cancel_delayed_work

In this case cancel_dalyed_work_sync (CPU2) will wait for CPU1 to
complete but CPU1 will re-arm the work, and we will
be left with tstamp->overflow_work running forever.

>> +     write_unlock_irqrestore(&tstamp->lock, flags);
>> +}
>
>> +void mlx5e_timestamp_cleanup(struct mlx5e_priv *priv)
>> +{
>> +     struct mlx5e_tstamp *tstamp = &priv->tstamp;
>> +
>> +     if (!MLX5_CAP_GEN(priv->mdev, device_frequency_khz))
>> +             return;
>> +
>> +     write_lock(&tstamp->lock);
>> +     tstamp->overflow_period = 0; /* Signal overflow_check to stop */
>> +     write_unlock(&tstamp->lock);
>
> This is unnecessary because
>
>> +
>> +     cancel_delayed_work_sync(&tstamp->overflow_work);
>
> this will block until the work is cancelled.
>
see my previous comment it sure will block but without the protected
signal " tstamp->overflow_period = 0;"
the work can reschedule itself.

>> +}
>
> Thanks,
> Richard
>
>
