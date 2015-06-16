From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH v4 3/3] net/xen-netback: Don't mix hexa and decimal with
 0x in the printf format
Date: Tue, 16 Jun 2015 16:55:19 -0700
Message-ID: <1434498919.2689.35.camel@perches.com>
References: <1434481848-26387-1-git-send-email-julien.grall@citrix.com>
	 <1434481848-26387-4-git-send-email-julien.grall@citrix.com>
	 <5580821D.4080408@cogentembedded.com> <1434492550.2689.8.camel@perches.com>
	 <5580A33C.4040007@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Julien Grall <julien.grall@citrix.com>,
	xen-devel@lists.xenproject.org, linux-kernel@vger.kernel.org,
	Wei Liu <wei.liu2@citrix.com>,
	Ian Campbell <ian.campbell@citrix.com>, netdev@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5580A33C.4040007@cogentembedded.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2015-06-17 at 01:29 +0300, Sergei Shtylyov wrote:
> Hello.
> 
> On 06/17/2015 01:09 AM, Joe Perches wrote:
> 
> >>> Append 0x to all %x in order to avoid while reading when there is other
> >>> decimal value in the log.
> 
> > []
> 
> >>> @@ -874,7 +874,7 @@ static inline void xenvif_grant_handle_set(struct xenvif_queue *queue,
> >>>    	if (unlikely(queue->grant_tx_handle[pending_idx] !=
> >>>    		     NETBACK_INVALID_HANDLE)) {
> >>>    		netdev_err(queue->vif->dev,
> >>> -			   "Trying to overwrite active handle! pending_idx: %x\n",
> >>> +			   "Trying to overwrite active handle! pending_idx: 0x%x\n",
> 
> >>      Using "%#x" is shorter ind does the same.
> 
> > That's true, but it's also far less common.
> 
>     Which is a pity... People just don't know the format specifiers well 
> enough. :-(
> 
> > $ git grep -E "%#[\*\d\.]*x" | wc -l
> > 1419
> > $ git grep "0x%" | wc -l
> > 29844
> 
>     Which means 29 KB could theoretically be saved on allyesconfig build. :-)
> (Actually less since the width specifiers will likely need to be fixed where 
> present.)

And less than that because a lot of these are in
arch specific code.

0x%x is easier and simpler to visualize than %#x.

But you are welcome to try to make the kernel smaller.
One byte at a time.

There are ~14.5k uses of 0x%x in ~10.5k lines and
~2600 files that would be changed.

That's a lot of lines and a lot of patches.

$ git grep --name-only "0x%x" | xargs sed -i -e 's/0x%x/%#x/g'
$ git diff | wc
  96250  415388 3949872

Only a 4M patch.

The pretty common (~5k) "0x%08x" would be "%#010x"
so that doesn't save any space.

but this one's a ~3.5M patch.

$ git grep --name-only -P "0x%\d+\w*x" | xargs perl -p -i -e 's/0x%0(\d+)(\w*)x/"\%#0" . eval($1 + 2) . "$2x"/eg'
$ git diff | wc
  80857  344565 3306990

enjoy...
