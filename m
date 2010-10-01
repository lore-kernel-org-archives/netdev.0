From: Robin Holt <holt@sgi.com>
Subject: Re: [PATCH V3] fs: allow for more than 2^31 files
Date: Thu, 30 Sep 2010 23:34:13 -0500
Message-ID: <20101001043413.GN14068@sgi.com>
References: <20100923121704.GR14064@sgi.com>
 <1285246384.362.3.camel@edumazet-laptop>
 <20100923141037.GA3811@in.ibm.com>
 <20100927.153639.212415479.davem@davemloft.net>
 <1285645611.10438.27.camel@edumazet-laptop>
 <20100930202612.GM14068@sgi.com>
 <1285879545.2705.4.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Robin Holt <holt@sgi.com>, David Miller <davem@davemloft.net>,
	dipankar@in.ibm.com, viro@zeniv.linux.org.uk, bcrl@kvack.org,
	den@openvz.org, mingo@elte.hu, mszeredi@suse.cz, cmm@us.ibm.com,
	npiggin@kernel.dk, xemul@openvz.org, linux-kernel@vger.kernel.org,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1285879545.2705.4.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 30, 2010 at 10:45:45PM +0200, Eric Dumazet wrote:
> Le jeudi 30 septembre 2010 =E0 15:26 -0500, Robin Holt a =E9crit :
> > On Tue, Sep 28, 2010 at 05:46:51AM +0200, Eric Dumazet wrote:
> > > Le lundi 27 septembre 2010 =E0 15:36 -0700, David Miller a =E9cri=
t :
> > ...
> >=20
> > > Fix is to let /proc/sys/fs/file-nr & /proc/sys/fs/file-max use lo=
ng
> > > integers, and change af_unix to use an atomic_long_t instead of
> > > atomic_t.
> > >=20
> > > get_max_files() is changed to return an unsigned long.
> >=20
> > I _THINK_ we actually want get_max_files to return a long and have
> > the files_stat_struct definitions be longs.  If we do not have it t=
hat
> > way, we could theoretically open enough files on a single cpu to ma=
ke
> > get_nr_files return a negative without overflowing max_files.  That=
,
> > of course, would require an insane amount of memory, but I think it=
 is
> > technically more correct.
> >=20
>=20
> Number of opened file is technically a positive (or null) value, I ha=
ve
> no idea why you want it being signed.
>=20
> >=20
> > > --- a/kernel/sysctl.c
> > > +++ b/kernel/sysctl.c
> > > @@ -1352,16 +1352,16 @@ static struct ctl_table fs_table[] =3D {
> > >  	{
> > >  		.procname	=3D "file-nr",
> > >  		.data		=3D &files_stat,
> > > -		.maxlen		=3D 3*sizeof(int),
> > > +		.maxlen		=3D sizeof(files_stat),
> > >  		.mode		=3D 0444,
> > > -		.proc_handler	=3D proc_nr_files,
> > > +		.proc_handler	=3D proc_doulongvec_minmax,
> >=20
> > With this change, don't we lose the current nr_files value?  I thin=
k
> > you need proc_nr_files to stay as it was.  If you disagree, we shou=
ld
> > probably eliminate the definitions for proc_nr_files as I don't bel=
ieve
> > they are used anywhere else.
> >=20
>=20
> I have no idea why you think I changed something. I only made the val=
ue
> use 64bit on 64bit arches, so that we are not anymore limited to 2^31
> files.

The proc_handler used to be proc_nr_files() which would call
get_nr_files() and deposit the result in files_stat.nr_files then casca=
de
to proc_dointvec() which would dump the 3 values.  Now it will dump the
three values, but not update the middle (nr_files) value first.

Robin
