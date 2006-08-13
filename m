From: Jeff Carr <basilarchia@gmail.com>
Subject: Re: [take8 1/2] kevent: Core files.
Date: Sat, 12 Aug 2006 17:51:41 -0700
Message-ID: <44DE779D.8060609@gmail.com>
References: <11552856103972@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: lkml <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Ulrich Drepper <drepper@redhat.com>,
	Andrew Morton <akpm@osdl.org>, netdev <netdev@vger.kernel.org>,
	Zach Brown <zach.brown@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.183]:29565 "EHLO
	py-out-1112.google.com") by vger.kernel.org with ESMTP
	id S932631AbWHMAuM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Aug 2006 20:50:12 -0400
Received: by py-out-1112.google.com with SMTP id z74so3634196pyg
        for <netdev@vger.kernel.org>; Sat, 12 Aug 2006 17:50:12 -0700 (PDT)
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
In-Reply-To: <11552856103972@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/11/06 01:40, Evgeniy Polyakov wrote:

> +/*
> + * Inode events.
> + */
> +#define	KEVENT_INODE_CREATE	0x1
> +#define	KEVENT_INODE_REMOVE	0x2

It would be useful to have gnome/kde notification when hard drives start
failing. There was some talk in the past about how to implement that
with kobjects. Perhaps you could add for this purpose:

#define	KEVENT_BLOCK_CREATE	0x1
#define	KEVENT_BLOCK_REMOVE	0x2
#define	KEVENT_BLOCK_ERROR	0x4

AFAICT:
The conversation concluded this is the best way to handle ioerrors:

--- a/fs/buffer.c
+++ b/fs/buffer.c
@@ -108,6 +108,8 @@ static void buffer_io_error(struct buffe
 	printk(KERN_ERR "Buffer I/O error on device %s, logical block %Lu\n",
 			bdevname(bh->b_bdev, b),
 			(unsigned long long)bh->b_blocknr);
+
+	kevent_block_error(&bh->b_bdev->bd_disk->kobj);
 }

 /*
--- a/fs/direct-io.c
+++ b/fs/direct-io.c
@@ -252,8 +252,11 @@ static void finished_one_bio(struct dio
 				transferred = dio->i_size - offset;

 			/* check for error in completion path */
-			if (dio->io_error)
+			if (dio->io_error) {
 				transferred = dio->io_error;
+				kevent_block_error(
+				&dio->bio->bi_bdev->bd_disk->kobj);
+			}

 			dio_complete(dio, offset, transferred);

