From: Jouni Malinen <jkmaline@cc.hut.fi>
Subject: Re: [RFC] acx100 inclusion in mainline; generic 802.11 stack
Date: Tue, 31 Aug 2004 19:22:05 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040901022205.GB7366@jm.kir.nu>
References: <200408312111.02438.vda@port.imtp.ilyichevsk.odessa.ua> <4134C1A7.50600@pobox.com> <200408312214.44701.vkondra@mail.ru> <20040831213719.GH31207@ruslug.rutgers.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: Vladimir Kondratiev <vkondra@mail.ru>, netdev@oss.sgi.com,
        Jeff Garzik <jgarzik@pobox.com>,
        Denis Vlasenko <vda@port.imtp.ilyichevsk.odessa.ua>,
        Jean Tourrilhes <jt@bougret.hpl.hp.com>,
        Jouni Malinen <jkmaline@cc.hut.fi>, acx100-devel@lists.sourceforge.net,
        prism54-devel@prism54.org, davem@redhat.com
Content-Disposition: inline
In-Reply-To: <20040831213719.GH31207@ruslug.rutgers.edu>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Aug 31, 2004 at 05:37:19PM -0400, Luis R. Rodriguez wrote:
> On Tue, Aug 31, 2004 at 10:14:38PM +0300, Vladimir Kondratiev wrote:
> > - Security is not up-to date either. We need .1x, EAS, TKIP etc. This need to 
> > be done for modern cards to use this infrastructure.
> 
> This is handled by hostap wpa_supplicant now, which is going to be part
> of WE18. The question I think is whether somoene plans on re-doing it on
> wireless-2.6, since as you mentioned it seems WE are being redone on
> davem's patch.

This sounds somewhat confusing.. As far as WPA and IEEE 802.11i
(RSN/WPA2) are concerned, there are number of different components
involved.

One part is in IEEE 802.11 data frame handling (TKIP, CCMP). This is
implemented, e.g., in the current Host AP RX/TX paths more or less
completely. The current implementation is still hardcoded to do this in
software, so it would need to be extended to support offloading
encryption to the wlan card since many of the modern cards have hardware
(or combination of hardware/firmware) implementation of TKIP and CCMP.
In addition, IEEE 802.11e will add some small changes to TKIP/CCMP
processing; Host AP code has places for this for TX (mainly, setting
priority value in the header). RX needs some more work because of
possible reordering of packets with different priorities. This all lives
in the generic 802.11 stack of the kernel.

In addition to data encryption, IEEE 802.11i defines key management
protocol (4-Way/PTK handshake, 2-Way/Group Key handshake) and
optimizations for full IEEE 802.1X authentication (PMKSA caching,
pre-authentication). IEEE 802.1X and EAP authentication is on similar
level. All these are done using EAPOL packet (own ethertype; one for
EAPOL and one for pre-authentication). This could be done in kernel, but
I don't see much point in that and have thus implemented these in user
space. wpa_supplicant includes the Supplicant part both for IEEE 802.1X
and IEEE 802.11i key handshakes. hostapd includes the Authenticator part
for the same functionality.

Being able to keep authentication and key management separated from the
data encryption. There needs to be an interface for configuring and
getting event information. I would say this can be considered as
separate design area. Currently, hostapd and wpa_supplicant are using
combination of ioctls (WE and private, depending on the driver) for user
space -> kernel configuration (e.g., encryption keys), wireless events
(netlink) for getting event information (association/encryption
error/etc.), network interfaces with or without IEEE 802.11 headers
(e.g., hostapd includes IEEE 802.11 headers for management frames in a
separate interface and wpa_supplicant uses just Ethernet header and
normal data interface to get the two special ethertypes).

This communication interface can be replaced with something different,
if desired, without affecting the other parts of the implementation (the
encryption of data frames itself or the authentication/key management
protocols).

-- 
Jouni Malinen                                            PGP id EFC895FA
