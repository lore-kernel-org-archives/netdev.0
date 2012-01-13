From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: brcm80211 breakage..
Date: Thu, 12 Jan 2012 16:13:30 -0800
Message-ID: <CA+55aFxZ7H=x2-rgQgRE9b=ky-h0WM1x-48Zs8a0dVt0NvkB_g@mail.gmail.com>
References: <CA+55aFxw5e3EYCGYjkWiTmhy9-WaY4T_-MF7EYcn4jXuBoxAgw@mail.gmail.com>
 <4F0D6806.4080201@broadcom.com> <CA+55aFxzFKkUPSCU6Wr_FBPd6NFPeTctGR0kpqYJJ8fcw+ck7w@mail.gmail.com>
 <CA+55aFw7TdNzNi86cwF4o6xSWnbKuPS5CuhdbChzoboNw_1-Tw@mail.gmail.com>
 <4F0DC030.6090500@lwfinger.net> <CA+55aFyAX_OdE7yNp1vM1AmywrYZ9Pvr0EX47jNQciZKOQUQHg@mail.gmail.com>
 <4F0E3B7E.8040005@lwfinger.net> <CA+55aFyR9C8GjhKb8orr1kgd_G23=-mcmT-uz9zJd6wk7rYDPA@mail.gmail.com>
 <4F0E5E57.9060204@lwfinger.net> <CA+55aFw0XArx0jpNh4dWYFmvJbb+GJYAWRUN2Ec14oREiATo7g@mail.gmail.com>
 <CA+55aFxDOr_TT+kxp1SuwNFfm7KLTaWSLQwk1Fx8fWe7tdstcg@mail.gmail.com>
 <CA+55aFzkCXnHfF_TO5M+gaN4RMvj_WNuW_QeBezuYBdWnwPDpg@mail.gmail.com>
 <CA+55aFx2UnVZP1Z44dMHeifB2nD1zJ87kz25zZjUdwv0ozwKPA@mail.gmail.com>
 <CA+55aFzNJbM=ohXninJ06518e3a6E8vySg8GT6dx+Qovk1QW0Q@mail.gmail.com>
 <4F0F3DEC.4050605@broadcom.com> <CA+55aFw==r4TF5WPn5Ggz32m7yi2T71Ghdx+7ME=pEjQLqU=uw@mail.gmail.com>
 <CA+55aFxMh0T1W06YHepcPAyemcR4rrxghQeRKsW3MtT+gNK9eg@mail.gmail.com>
 <CACna6rwVTN6jQuAjVFN0p8QRVpt89ne7LxKbcmoorbZFtxFLkQ@mail.gmail.com>
 <CA+55aFz8z9V5vxBMAH3TFVmROj0C-8Mb+G0Ki=Yuai5_KG893A@mail.gmail.com> <CACna6rzeTmQu0c1=f6gizG_=XRkt3FdB7c_sAJtktjLdFmTQ3g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Arend van Spriel <arend@broadcom.com>,
	Larry Finger <Larry.Finger@lwfinger.net>,
	Alwin Beukers <alwin@broadcom.com>,
	Roland Vossen <rvossen@broadcom.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Network Development <netdev@vger.kernel.org>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>
To: =?ISO-8859-2?Q?Rafa=B3_Mi=B3ecki?= <zajec5@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:63708 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756073Ab2AMANv convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2012 19:13:51 -0500
Received: by ggdk6 with SMTP id k6so1356159ggd.19
        for <netdev@vger.kernel.org>; Thu, 12 Jan 2012 16:13:51 -0800 (PST)
In-Reply-To: <CACna6rzeTmQu0c1=f6gizG_=XRkt3FdB7c_sAJtktjLdFmTQ3g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2012/1/12 Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com>:
>
> Have you tried booting with bcma & brcmsmac blacklisted? Does
> suspend&resume work then?
>
> Have you tried blacklisting just brcmsmac (letting bcma load)? Does
> s&r work then?

If I unload brcmsmac, I can suspend/resume. Once. It can't suspend a
second time.

I did see some message flash about "does not have a release()
function", but don't know if that was bcma or something else.

I do notice that both the bcma and suspend/resume seems quite broken.
It's using the legacy suspend/resume stuff and does the PCI resume on
its own (with no matching suspend!). That *really* isn't a good idea
these days.

The way to do it these days is to have a struct dev_pm_ops embedded in
the struct pci_driver (".driver.pm"), and let the PCI layer handle all
the generic PCI suspend/resume  details - you only handle the
device-specific ones (ie in this case suspending/resuming the bcma bus
itself).

The generic PCI layer will do all the PCI stuff correctly, including
all the nasty races with shared interrupts etc. In a way that no
driver ever got it right. And it simplifies the driver too.

And the brcms driver does suspend/resume *completely* wrong, and seems
to actually re-suspend and re-resume the PCI device.

I'm surprised it has ever worked for anybody. It certainly doesn't work=
 for me.

                      Linus
