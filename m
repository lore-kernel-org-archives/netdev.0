From: =?UTF-8?Q?Sjur_Br=C3=A6ndeland?= <sjurbren@gmail.com>
Subject: Re: [PATCH] net: caif: Don't act on notification for non-caif devices
Date: Tue, 24 Jan 2012 16:06:32 +0100
Message-ID: <CAJK669ZWJsxnSiyKWFFFUWOA3TaGMY-AmgWuVsYfR=tKQaODgg@mail.gmail.com>
References: <1327390229-30170-1-git-send-email-levinsasha928@gmail.com>
	<CAJK669acbPLTxTDrk_uqdB2FmewcSA+HF0qEFADgT8YdfNMcpQ@mail.gmail.com>
	<1327416561.32498.10.camel@lappy>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: davem@davemloft.net, davej@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Sasha Levin <levinsasha928@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1327416561.32498.10.camel@lappy>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Sasha,

>> Nack, we have to handle other device types than just ARPHDR_CAIF after
>> introducing CAIF over USB/NCM.
> What my patch did was simply move the type check to above the net_generic call,
> it didn't add any new checks - which according to what you said, you'll need to do anyway.

As I said I, don't think your patch would work. Try to see what happens if
dev->type != ARPHDR_CAIF and caifd != NULL. Then the statement:

	if (caifd == NULL && dev->type != ARPHRD_CAIF)
		return 0;
is very different from:

       if (dev->type != ARPHRD_CAIF)
               return 0;
...
       if (caifd == NULL)
               return 0;

Anyway, another option could be to explicitly check if name space is
initialized,
similar to what net_generic() does,e.g. something like:

diff --git a/net/caif/caif_dev.c b/net/caif/caif_dev.c
index 673728a..3197bc2 100644
--- a/net/caif/caif_dev.c
+++ b/net/caif/caif_dev.c
@@ -371,6 +371,13 @@ static int caif_device_notify(struct notifier_block *me, un
        struct cflayer *layer, *link_support;
        int head_room = 0;
        struct caif_device_entry_list *caifdevs;
+       int len;
+
+       rcu_read_lock();
+       len = rcu_dereference(dev_net(dev)->gen)->len;
+       rcu_read_unlock();
+       if (caif_net_id > len)
+               return 0;

        cfg = get_cfcnfg(dev_net(dev));
        caifdevs = caif_device_list(dev_net(dev));
--

Regards,
Sjur
