From: Robin Holt <holt@sgi.com>
Subject: Re: [PATCH V3] fs: allow for more than 2^31 files
Date: Thu, 30 Sep 2010 15:26:12 -0500
Message-ID: <20100930202612.GM14068@sgi.com>
References: <20100923121704.GR14064@sgi.com>
 <1285246384.362.3.camel@edumazet-laptop>
 <20100923141037.GA3811@in.ibm.com>
 <20100927.153639.212415479.davem@davemloft.net>
 <1285645611.10438.27.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, dipankar@in.ibm.com,
	holt@sgi.com, viro@zeniv.linux.org.uk, bcrl@kvack.org,
	den@openvz.org, mingo@elte.hu, mszeredi@suse.cz, cmm@us.ibm.com,
	npiggin@kernel.dk, xemul@openvz.org, linux-kernel@vger.kernel.org,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay1.sgi.com ([192.48.179.29]:56793 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932116Ab0I3U0S (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Sep 2010 16:26:18 -0400
Content-Disposition: inline
In-Reply-To: <1285645611.10438.27.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 28, 2010 at 05:46:51AM +0200, Eric Dumazet wrote:
> Le lundi 27 septembre 2010 =E0 15:36 -0700, David Miller a =E9crit :
=2E..

> Fix is to let /proc/sys/fs/file-nr & /proc/sys/fs/file-max use long
> integers, and change af_unix to use an atomic_long_t instead of
> atomic_t.
>=20
> get_max_files() is changed to return an unsigned long.

I _THINK_ we actually want get_max_files to return a long and have
the files_stat_struct definitions be longs.  If we do not have it that
way, we could theoretically open enough files on a single cpu to make
get_nr_files return a negative without overflowing max_files.  That,
of course, would require an insane amount of memory, but I think it is
technically more correct.


> --- a/kernel/sysctl.c
> +++ b/kernel/sysctl.c
> @@ -1352,16 +1352,16 @@ static struct ctl_table fs_table[] =3D {
>  	{
>  		.procname	=3D "file-nr",
>  		.data		=3D &files_stat,
> -		.maxlen		=3D 3*sizeof(int),
> +		.maxlen		=3D sizeof(files_stat),
>  		.mode		=3D 0444,
> -		.proc_handler	=3D proc_nr_files,
> +		.proc_handler	=3D proc_doulongvec_minmax,

With this change, don't we lose the current nr_files value?  I think
you need proc_nr_files to stay as it was.  If you disagree, we should
probably eliminate the definitions for proc_nr_files as I don't believe
they are used anywhere else.


Thanks,
Robin
