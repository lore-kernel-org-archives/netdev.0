From: "Luis R. Rodriguez" <mcgrof-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Backporting the Linux kernel, for good - was: Re: semantic patch inference
Date: Fri, 9 Sep 2011 12:58:48 -0700
Message-ID: <CAB=NE6U0ks9CobukO04=bZpnkm3Yw+Pf7keVPsP-hv1NyJZ_Xw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Julia Lawall <julia-dAYI7NvHqcQ@public.gmane.org>, Jesper Andersen <jespera-dAYI7NvHqcQ@public.gmane.org>,
	Hauke Mehrtens <hauke-5/S+JYg5SzeELgA04lAiVw@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Taking this to the lists for more eyeball review. Some background to
folks who were not at Plumbers or at the 'Backporting the Linux
kernel, for good' BoF:

http://www.linuxplumbersconf.org/2011/ocw/proposals/771
http://www.linuxplumbersconf.org/2011/ocw//system/presentations/771/ori=
ginal/kernel-backport-for-good.odp

In short there are some metrics I have finally evaluated from the
compat work we have. Each backported tarball provides metrics of how
much lines of code we take from upstream, how much work is required
through patches for backport work, and also how many lines of code go
into the generic Linux kernel compatibility module. The talk dissected
these metrics for the first time and provides some conclusions as to
what we can do better, what the estimated cost is of backporting new
subsystems, and some evolutionary practices that we can likely embrace
to make backporting even more automatic which would not only use
spatch but also Jesper's spdiff work. If you are interested in the
metrics stuff please review the slides and if you have questions feel
free to shoot here but below I review with Julia inquiries about
assumptions on how we backport stuff in consideration of spdiff work.

=46or those curious of spdiff here's a paper on 'Generic Patch
Inference' which explains the logistics behind it:

http://www.diku.dk/~julia/andersen_ase08.pdf

In short, spatch files can be used on target directories to generate
patches. spdiff can read a patch file and generate an spatch file for
you. What this means for the backporting world is if you backport one
evolutionary change in the Linux kernel for one driver you can then
backport the same change for *all* drivers. This is a quantum leap in
terms of effort required to backport.

Anyway, some details on review of assumptions below.

On Fri, Sep 9, 2011 at 6:18 AM, Julia Lawall <julia-dAYI7NvHqcQ@public.gmane.org> wrote:
> Hi,
>
> After some sleep it all seems more clear :)

:)

> First, the choice of patches from linux-next is not our problem.

Exactly! We just

cp -a $COMPAT/ .
cp -a $LINUX_NEXT/subsystem/ .
for i in foo bar
  cp -a drivers/$i .
done

> Second, perhaps we could assume that the patches in compat are always=
 of
> the form
>
> +#ifdef version <=3D n
> +new code
> +#else
> old code
> +#endif
>
> (and variants - I see that sometimes there is >). =C2=A0We are going =
to want to
> treat that as
>
> + new code
> - old code
>
> for the inference process, but I can see that it is very important to=
 have
> the version numbers associated with this information, so that can be
> regenerated in the chosen patch.

Yes, the variance of the #if's expands to other cases as well like:

+#if (LINUX_VERSION_CODE >=3D KERNEL_VERSION(2,6,39))
        netdev->hw_features =3D NETIF_F_SG | NETIF_F_HW_VLAN_RX;
+#endif
+#if defined(NETIF_F_HW_VLAN_TX) || (LINUX_VERSION_CODE >=3D
KERNEL_VERSION(2,6,39))
        netdev->features |=3D (NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX)=
;
+#endif

But I'm not even sure why I allowed this to go in, it makes more sense
to remove the flag check on the second if defined. That sort of check
though might be an alternative approach we can check for instead of
kernel versions though, Johannes wanted to see if he can do
backporting this way a while ago but I am not sure up to where he got
up to. Reason for checking for features instead of kernel versions is
some Linux distributions mangle their kernels with features from
future kernels and still keep the same kernel release number. This
makes some kernel backport assumptions incorrect for some of these
distributions and this is why we likely have some of these feature
checks in addition to kernel version checks.

At this point though I feel as if adding a feature label for each
backport work item might be a bit too much work, and sticking to
kernel versions is the way to go. If the work to deal with other
variants is a bit too much then I'd say we can keep those oddball
variants in separate files.

Additionally there is quite a bit of work on the patches/ directory
that can be done to help improve the situation for inspection
purposes. Although each file there does handle specific backport work
items they can be split out even more atomically. Consider the
01-netdev.patch. That has the netdev ops thingy, but also

+#if (LINUX_VERSION_CODE < KERNEL_VERSION(2,6,29))
+       /* can't we remove this? */
+       net->change_mtu =3D NULL;
+#endif

Note that I am not sure if we can just ignore this, but its just one
example. This random set of bits that do not relate to netdev ops can
be extracted into another file -- unless the work you have may be able
to address multiple work items from one file. If its just targeted for
one work item we can clean this stuff up further to help with that
process.

> Jesper's work takes a patch and the before and after versions of the
> given files in the original code, and finds a semantic patch that tak=
es
> the before code safely to the after code.

:)

> But compat-wireless seems to apply to all versions.

Nope, the patches in the patches/ directory are targeted to apply
cleanly to work in linux-next.git. At times the patches may not apply
cleanly with hunk offsets being off a bit but that is cleaned up
easily through quilt refresh (./scripts/admin-update.sh refresh),
after that the patches will apply cleanly onto linux-next.git.

I should note though that the patches in the patches/ directory
account for backporting effort for *all* supported kernel versions
though. Today my goal is to try at the very least to support down to
the last *supported* 2.6 stable kernel. Work for older kernels is
welcomed though but I think supporting down to the latest stable is a
decent goal.

> So he should interpret the #ifs to figure out what versions a specifi=
c change applies to,

Right, to what kernel version, lets call it, a 'backport work item' ref=
ers to.

> and then apply the semantic patch inference process to all of those v=
ersions?

Yes. But I should note that if the semantic patch inference process
works atomically on only one type of change per reviewed file then
some work is required to split up the patches a bit better. In the
01-netdev.patch we have *most* netdev evolutionary changes in the
kernel that we need to backport, not just one.

> I guess he could take a compat patch and a list of versions, and gene=
rate a
> patch with the appropriate
>
> + new code
> - old code
>
> for each of those versions.

Typically the patches address changes for *any* kernel release older
than specific version, splitting the changes for individual kernels is
possible but would be possible but would lead to a bit of redundancy
in work required given that the same change is required for multiple
older supported kernel versions. I will note though that at times the
checks may make some exception to one kernel, but I do not think that
the patches/ directory has any of those, instead I think we have that
dealt with in the compat module -- that is not in patch files.

> Then he could run his tool on those patches and the corresponding ver=
sions, and then
> make a semantic patch that includes the appropriate #ifs that could a=
pply to all versions.

Well so in practice the patches/ files address a range of kernels for
which a backport work item is required for can the tool can be made to
infer a set of conditions under which the work item applies to ? In
this case it would be a range of kernel versions.

> If that all seems correct to you, perhaps it is not necessary for you=
 to
> come up from SFO today :)

Ace! I got home at 11pm so it'd be great if I can stay but I do value
this work ****a lot**** so will head out shortly if you think its best
to review in person.

  Luis
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
