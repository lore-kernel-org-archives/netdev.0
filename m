From: Andy Shevchenko <andy.shevchenko@gmail.com>
Subject: Re: [PATCH] ath6kl: Use vmalloc to allocate ar->fw for api1 method
Date: Sun, 13 Dec 2015 02:52:39 +0200
Message-ID: <CAHp75VdOwJbgm1Hr7UmUss2iWnaujVoLVvwpg7D9B=VA8qs-Qw@mail.gmail.com>
References: <1448948470-31111-1-git-send-email-motobud@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT
Cc: Kalle Valo <kvalo@qca.qualcomm.com>,
	"open list:TI WILINK WIRELES..." <linux-wireless@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	ath6kl@lists.infradead.org
To: Brent Taylor <motobud@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f176.google.com ([209.85.220.176]:33111 "EHLO
	mail-qk0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751187AbbLMAwk convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Dec 2015 19:52:40 -0500
In-Reply-To: <1448948470-31111-1-git-send-email-motobud@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 1, 2015 at 7:41 AM, Brent Taylor <motobud@gmail.com> wrote:
> Since commit 8437754c83351d6213c1a47ff029c1126d6042a7, ar->fw is expected to be pointing to memory allocated by vmalloc.  If the api1 method (via ath6kl_fetch_fw_api1) is used to allocate memory for ar->fw, then kmemdup is used.  This patch checks if the firmware being loaded is the 'fw' image, then use vmalloc, otherwise use kmalloc.
>

I think I already told someone that this kind of fixes miss the
symmetric kvfree() calls. Please, fix.


> Signed-off-by: Brent Taylor <motobud@gmail.com>
> ---
>  drivers/net/wireless/ath/ath6kl/init.c | 7 ++++++-
>  1 file changed, 6 insertions(+), 1 deletion(-)
>
> diff --git a/drivers/net/wireless/ath/ath6kl/init.c b/drivers/net/wireless/ath/ath6kl/init.c
> index 6ae0734..4f2b124d 100644
> --- a/drivers/net/wireless/ath/ath6kl/init.c
> +++ b/drivers/net/wireless/ath/ath6kl/init.c
> @@ -673,10 +673,15 @@ static int ath6kl_get_fw(struct ath6kl *ar, const char *filename,
>                 return ret;
>
>         *fw_len = fw_entry->size;
> -       *fw = kmemdup(fw_entry->data, fw_entry->size, GFP_KERNEL);
> +   if (&ar->fw == fw)
> +               *fw = vmalloc(fw_entry->size);
> +   else
> +               *fw = kmalloc(fw_entry->size, GFP_KERNEL);
>
>         if (*fw == NULL)
>                 ret = -ENOMEM;
> +       else
> +               memcpy(*fw, fw_entry->data, fw_entry->size);
>
>         release_firmware(fw_entry);
>
> --
> 2.6.3
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/



-- 
With Best Regards,
Andy Shevchenko
