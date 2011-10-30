From: Jiri Slaby <jslaby@suse.cz>
Subject: Re: Broken link in /sys/class/net/ [was: [GIT] Networking]
Date: Sun, 30 Oct 2011 21:49:40 +0100
Message-ID: <4EADB864.3060702@suse.cz>
References: <20111025.063206.2273357152859701628.davem@davemloft.net> <CA+55aFw1GVvszqoC_f0RAvG5t1xj0CSYLhLU=y0gQ+_54Gsomw@mail.gmail.com> <20111025131315.GA1899@suse.de> <4EAC8642.3050309@suse.cz> <m11utvytg4.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Jiri Slaby <jirislaby@gmail.com>, Greg KH <gregkh@suse.de>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	David Miller <davem@davemloft.net>,
	Mikulas Patocka <mpatocka@redhat.com>,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:37153 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752100Ab1J3Utp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Oct 2011 16:49:45 -0400
In-Reply-To: <m11utvytg4.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/30/2011 05:49 AM, Eric W. Biederman wrote:
> Jiri Slaby <jslaby@suse.cz> writes:
> 
>> On 10/25/2011 03:13 PM, Greg KH wrote:
>>> On Tue, Oct 25, 2011 at 01:46:11PM +0200, Linus Torvalds wrote:
>>>> Anyway, after that rant about really bad practices, let me say that I
>>>> did fix up the conflict and I think it's right. But I won't guarantee
>>>> it, so please check the changes to fs/sysfs/dir.c.
>>>
>>> I think it looks ok, I've booted the merge result, and am typing and
>>> sending this from the new kernel, and it hasn't crashed yet :)
>>
>> Hi, maybe this was not caused by the merge, but the patch[1] causes this
>> mess in /sys/class/net/ for me:
>> l????????? ? ?    ?    ?             ? eth1
>>
>> This happens after one renames a net device -- the new name is eth1 here.
>>
>> [1] 4f72c0cab40 (sysfs: use rb-tree for name lookups)
> 
> This looks pretty fixable but today sysfs_rename does not do anything
> with the to move a renamed entry to a different position in the rbtree.
> 
> If the directory itself changes sysfs_rename should be fine, and it
> looks like a trivial patch to always apply the directory rename logic
> in sysfs_rename. 
> 
> I think all we need is something like the untested patch below to fix
> the network device rename problem.

Looks like it works. Thanks.

> diff --git a/fs/sysfs/dir.c b/fs/sysfs/dir.c
> index 48ffbdf..a294068 100644
> --- a/fs/sysfs/dir.c
> +++ b/fs/sysfs/dir.c
> @@ -865,14 +865,13 @@ int sysfs_rename(struct sysfs_dirent *sd,
>  		sd->s_name = new_name;
>  	}
>  
> -	/* Remove from old parent's list and insert into new parent's list. */
> -	if (sd->s_parent != new_parent_sd) {
> -		sysfs_unlink_sibling(sd);
> -		sysfs_get(new_parent_sd);
> -		sysfs_put(sd->s_parent);
> -		sd->s_parent = new_parent_sd;
> -		sysfs_link_sibling(sd);
> -	}
> +	/* Move to the appropriate place in the appropriate directories rbtree. */
> +	sysfs_unlink_sibling(sd);
> +	sysfs_get(new_parent_sd);
> +	sysfs_put(sd->s_parent);
> +	sd->s_parent = new_parent_sd;
> +	sysfs_link_sibling(sd);
> +
>  	sd->s_ns = new_ns;
>  
>  	error = 0;
> 


-- 
js
suse labs
