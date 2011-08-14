From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH] virtio-net: Read MAC only after initializing MSI-X
Date: Sun, 14 Aug 2011 12:23:44 +0930
Message-ID: <878vqw9007.fsf@rustcorp.com.au>
References: <1313225461-24458-1-git-send-email-levinsasha928@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sasha Levin <levinsasha928@gmail.com>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	kvm@vger.kernel.org
To: Sasha Levin <levinsasha928@gmail.com>, linux-kernel@vger.kernel.org
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <1313225461-24458-1-git-send-email-levinsasha928@gmail.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 13 Aug 2011 11:51:01 +0300, Sasha Levin <levinsasha928@gmail.com> wrote:
> The MAC of a virtio-net device is located at the first field of the device
> specific header. This header is located at offset 20 if the device doesn't
> support MSI-X or offset 24 if it does.

Erk.  This means, in general, we have to do virtio_find_single_vq or
config->find_vqs before we examine any config options.

Look at virtio_blk, which has the same error.

Solutions in order of best to worst:
(1) Enable MSI-X before calling device probe.  This means reserving two
    vectors in virtio_pci_probe to ensure we *can* do this, I think.  Michael?

(2) Ensure ordering of "find_vqs then access config space" statically.  This
    probably means handing the vqs array to virtio_config_val, so noone
    can call it before they have their virtqueues.

(3) Ensure ordering dynamically, ie. BUG_ON() if they haven't done
    find_vqs when they call the config accessors.

If (1) is too invasive for -stable, then we should rearrange the drivers
in separate patches (and cc: -stable), then fix it properly.

Good catch Sasha!

Cheers,
Rusty.
