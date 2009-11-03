From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/3] sysfs directory scaling: rbtree for dirent name lookups
Date: Tue, 03 Nov 2009 07:14:33 +0100
Message-ID: <4AEFCA49.4020305@gmail.com>
References: <20091101163130.GA7911@kvack.org> <20091103035058.GA19515@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Benjamin LaHaise <bcrl@lhnet.ca>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Octavian Purdila <opurdila@ixiacom.com>,
	netdev@vger.kernel.org, Cosmin Ratiu <cratiu@ixiacom.com>,
	linux-kernel@vger.kernel.org
To: Greg KH <greg@kroah.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752818AbZKCGOo@vger.kernel.org>
In-Reply-To: <20091103035058.GA19515@kroah.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Greg KH a =E9crit :
> On Sun, Nov 01, 2009 at 11:31:30AM -0500, Benjamin LaHaise wrote:
>> Use an rbtree in sysfs_dirent to speed up file lookup times
>>
>> Systems with large numbers (tens of thousands and more) of network=20
>> interfaces stress the sysfs code in ways that make the linear search=
 for=20
>> a name match take far too long.  Avoid this by using an rbtree.
>=20
> What kind of speedups are you seeing here?  And do these changes caus=
e a
> memory increase due to the structure changes which outweigh the
> speedups?
>=20
> What kind of test are you doing to reproduce this?
>=20

Its curious because in my tests the biggest problems come from
kernel/sysctl.c (__register_sysctl_paths) consuming 80% of cpu
in following attempt to create 20.000 devices

(disable hotplug before trying this, and ipv6 too !)
modprobe dummy numdummies=3D20000

I believe we should address __register_sysctl_paths() scalability
problems too.

I dont know what is the 'sentinel' we allocate after each struct ctl_ta=
ble
But I suspect we could reduce size requirement of the 'sentinel' to inc=
lude
only needed fields for the sentinel (and move them at start of ctl_tabl=
e)

        /*
         * For each path component, allocate a 2-element ctl_table arra=
y.
         * The first array element will be filled with the sysctl entry
         * for this, the second will be the sentinel (ctl_name =3D=3D 0=
).
         *
         * We allocate everything in one go so that we don't have to
         * worry about freeing additional memory in unregister_sysctl_t=
able.
         */
        header =3D kzalloc(sizeof(struct ctl_table_header) +
                         (2 * npath * sizeof(struct ctl_table)), GFP_KE=
RNEL);

Then, adding an rb_node in ctl_table_header to speedup __register_sysct=
l_paths() a bit
