From: Brent Taylor <motobud@gmail.com>
Subject: Re: [PATCH] ath6kl: Use vmalloc to allocate ar->fw for api1 method
Date: Mon, 21 Dec 2015 15:53:44 -0600
Message-ID: <CAP+RiCBK_iEOu27GzqqgG9Pn_MDP1m8JCnSqkGbPMAT7=P9V7g@mail.gmail.com>
References: <1448948470-31111-1-git-send-email-motobud@gmail.com>
	<CAFqt6zaALx895c0BVrMpLdtfgYLz=-mmqaurtD28Nm1Ut2g1Dw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT
Cc: Kalle Valo <kvalo@qca.qualcomm.com>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	netdev@vger.kernel.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	ath6kl@lists.infradead.org
To: Souptick Joarder <jrdr.linux@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAFqt6zaALx895c0BVrMpLdtfgYLz=-mmqaurtD28Nm1Ut2g1Dw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Dec 21, 2015 at 1:23 PM, Souptick Joarder <jrdr.linux@gmail.com> wrote:
> Hi Brent,
>
> On Tue, Dec 1, 2015 at 11:11 AM, Brent Taylor <motobud@gmail.com> wrote:
>> Since commit 8437754c83351d6213c1a47ff029c1126d6042a7, ar->fw is expected to be pointing to memory allocated by vmalloc.  If the api1 method (via ath6kl_fetch_fw_api1) is used to allocate memory for ar->fw, then kmemdup is used.  This patch checks if the firmware being loaded is the 'fw' image, then use vmalloc, otherwise use kmalloc.
>>
>> Signed-off-by: Brent Taylor <motobud@gmail.com>
>> ---
>>  drivers/net/wireless/ath/ath6kl/init.c | 7 ++++++-
>>  1 file changed, 6 insertions(+), 1 deletion(-)
>>
>> diff --git a/drivers/net/wireless/ath/ath6kl/init.c b/drivers/net/wireless/ath/ath6kl/init.c
>> index 6ae0734..4f2b124d 100644
>> --- a/drivers/net/wireless/ath/ath6kl/init.c
>> +++ b/drivers/net/wireless/ath/ath6kl/init.c
>> @@ -673,10 +673,15 @@ static int ath6kl_get_fw(struct ath6kl *ar, const char *filename,
>>                 return ret;
>>
>>         *fw_len = fw_entry->size;
>> -       *fw = kmemdup(fw_entry->data, fw_entry->size, GFP_KERNEL);
>> +   if (&ar->fw == fw)
>> +               *fw = vmalloc(fw_entry->size);
>> +   else
>> +               *fw = kmalloc(fw_entry->size, GFP_KERNEL);
>
>           Why vmalloc and kmalloc both are required? can't use either
> vmalloc or kmalloc?

My original problem was that kmemdup (which uses kmalloc) could not
allocate enough memory
to hold the firmware that is placed into "ar->fw".  In the function
ath6kl_core_cleanup (in core.c),
the "ar->fw" pointer is the only one that uses vfree which was changed in commit
8437754c83351d6213c1a47ff029c1126d6042a7.

I was trying to change as little as possible and I wasn't sure if
there was a reason that any of the
other firmware items needed to be allocated with kmalloc or if they
could be changed to use vmalloc.
