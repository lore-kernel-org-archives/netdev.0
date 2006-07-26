From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [3/4] kevent: AIO, aio_sendfile() implementation.
Date: Wed, 26 Jul 2006 11:00:13 +0100
Message-ID: <20060726100013.GA7126@infradead.org>
References: <1153905495613@2ka.mipt.ru> <11539054952574@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: lkml <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Ulrich Drepper <drepper@redhat.com>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:7651 "EHLO
	pentafluge.infradead.org") by vger.kernel.org with ESMTP
	id S1750840AbWGZKAP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Jul 2006 06:00:15 -0400
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Content-Disposition: inline
In-Reply-To: <11539054952574@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 26, 2006 at 01:18:15PM +0400, Evgeniy Polyakov wrote:
> 
> This patch includes asynchronous propagation of file's data into VFS
> cache and aio_sendfile() implementation.
> Network aio_sendfile() works lazily - it asynchronously populates pages
> into the VFS cache (which can be used for various tricks with adaptive
> readahead) and then uses usual ->sendfile() callback.
> 
> Signed-off-by: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
> 
> diff --git a/fs/bio.c b/fs/bio.c
> index 6a0b9ad..a3ee530 100644
> --- a/fs/bio.c
> +++ b/fs/bio.c
> @@ -119,7 +119,7 @@ void bio_free(struct bio *bio, struct bi
>  /*
>   * default destructor for a bio allocated with bio_alloc_bioset()
>   */
> -static void bio_fs_destructor(struct bio *bio)
> +void bio_fs_destructor(struct bio *bio)
>  {
>  	bio_free(bio, fs_bio_set);
>  }
> diff --git a/fs/ext2/inode.c b/fs/ext2/inode.c
> index 04af9c4..295fce9 100644
> --- a/fs/ext2/inode.c
> +++ b/fs/ext2/inode.c
> @@ -685,6 +685,7 @@ ext2_writepages(struct address_space *ma
>  }
>  
>  struct address_space_operations ext2_aops = {
> +	.get_block		= ext2_get_block,

No way in hell.  For whatever you do please provide a interface at
the readpage/writepage/sendfile/etc abstraction layer.  get_block is
nothing that can be exposed to the common code.

