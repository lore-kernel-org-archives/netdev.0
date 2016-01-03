From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 0/5] xen-netback: Fine-tuning for three function
 implementations
Date: Sat, 02 Jan 2016 17:34:18 -0800
Message-ID: <1451784858.4334.12.camel@perches.com>
References: <566ABCD9.1060404@users.sourceforge.net>
	 <56880DD4.2090806@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: LKML <linux-kernel@vger.kernel.org>,
	kernel-janitors@vger.kernel.org,
	Julia Lawall <julia.lawall@lip6.fr>
To: SF Markus Elfring <elfring@users.sourceforge.net>,
	xen-devel@lists.xenproject.org, netdev@vger.kernel.org,
	Ian Campbell <ian.campbell@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <56880DD4.2090806@users.sourceforge.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2016-01-02 at 18:50 +0100, SF Markus Elfring wrote:
> A few update suggestions were taken into account
> from static source code analysis.

While static analysis can be useful, I don't think these
specific conversions are generally useful.

Perhaps it would be more useful to convert the string
duplication or snprintf logic to kstrdup/kasprintf

This:

	if (num_queues =3D=3D 1) {
		xspath =3D kzalloc(strlen(dev->otherend) + 1, GFP_KERNEL);
		if (!xspath) {
			xenbus_dev_fatal(dev, -ENOMEM,
					=A0"reading ring references");
			return -ENOMEM;
		}
		strcpy(xspath, dev->otherend);
	} else {
		xspathsize =3D strlen(dev->otherend) + xenstore_path_ext_size;
		xspath =3D kzalloc(xspathsize, GFP_KERNEL);
		if (!xspath) {
			xenbus_dev_fatal(dev, -ENOMEM,
					=A0"reading ring references");
			return -ENOMEM;
		}
		snprintf(xspath, xspathsize, "%s/queue-%u", dev->otherend,
			=A0queue->id);
	}

could be simplified to something like:

	if (num_queues =3D=3D 1)
		xspath =3D kstrdup(dev->otherend, GFP_KERNEL);
	else
		xspath =3D kasprintf(GFP_KERNEL, "%s/queue-%u",
				   dev->otherend, queue->id);
	if (!xspath)
		etc...
