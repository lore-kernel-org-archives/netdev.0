From: "Andonieh, Joe" <joe.andonieh@intel.com>
Subject: RE: RFC: Linux wireless extensions and WPA support
Date: Tue, 8 Jun 2004 10:36:25 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <386CBF9421521B41835E2BF21BEF80B8919069@hasmsx402.ger.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8bit
Cc: <netdev@oss.sgi.com>, "Jouni Malinen" <jkmaline@cc.hut.fi>
Return-path: <netdev-bounce@oss.sgi.com>
Content-class: urn:content-classes:message
To: <jt@hpl.hp.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

#define IW_AUTH_WPA_VERSION	0
---
#define IW_AUTH_WPA_VERSION_DISABLED	0
#define IW_AUTH_WPA_VERSION_WPA		1
#define IW_AUTH_WPA_VERSION_WPA2	2
---
#define IW_AUTH_CIPHER_PAIRWISE	1
#define IW_AUTH_CIPHER_GROUP	2
---
#define IW_AUTH_CIPHER_NONE	0
#define IW_AUTH_CIPHER_WEP40	1
#define IW_AUTH_CIPHER_TKIP	2
#define IW_AUTH_CIPHER_CCMP	4
#define IW_AUTH_CIPHER_WEP104	5

I wonder how this definition let you differentiate between the unicast
cipher and the group cipher? Moreover there is two information that are
needed

1) the authentication model, which is PSK or .1x
2) The cipher to connect with? 
	Shall we set both Pair wise and Group or only Pairwise and
connect with what ever group cipher in the RSN IE -- hint this will
enable smooth connection to mixed mode networks?

Please let me know what you think?

Thanks
Joe
-----Original Message-----
From: netdev-bounce@oss.sgi.com [mailto:netdev-bounce@oss.sgi.com] On
Behalf Of Jean Tourrilhes
Sent: Tuesday, June 08, 2004 3:27 AM
To: Jouni Malinen
Cc: netdev@oss.sgi.com
Subject: Re: RFC: Linux wireless extensions and WPA support

On Sun, Jun 06, 2004 at 07:34:55PM -0700, Jouni Malinen wrote:
> 
> I started working on WPA extension for the Linux wireless extensions
> based on our earlier discussion. This patch file for V16 shows my
> current work version. It is not yet ready to be merged into any tree
and
> is here mainly to allow review of the changes and generate some
> discussion (and well, to describe the changes without me having to
write
> a long email doing that ;-).

	Thanks a lot for that, Jouni !

> This has not yet been tested, but I'm starting to add support for it
> into the wireless-2.6 version of Host AP driver and wpa_supplicant.
I'll
> make an updated patch available once everything seems to be working.
> 
> To avoid using much more ioctl numbers, I extended the previously
> defined SIOCSIWENCODE/SIOCGIWENCODE and SIOCSIWSCAN instead of
defining
> new ioctls.

	Actually, I don't like the extension of SIOC*IWENCODE. This
ioctl is already messy/complex enough as it is, and I think we would
benefit greatly in separating the two code paths, therefore using a
new iotcl for it. It's not like we are short of ioctls.
	I'm worried about new-style driver returning extended
definition to old style tools, or new style tool sending extended
definitions to old style driver, or other stuff like that. Also,
driver author may thank us for keeping thing clearer.

	The extension of SIOCSIWSCAN was always something desired, but
I never got sure of which way it was supposed to be done (look at the
unused IW_SCAN_* flags in wireless.h).
	Do you think that ESSID is the only request filter that is
worthwhile ? Another option would be to allow an "iwevent" structure
allow to specify any kind of filter.
	If we decide that we will only ever filter on ESSID, then I
still don't understand the way you plan to use iw_scan_req. It doesn't
fit in 16 bytes, so it will be used with a struct
iw_point/IW_HEADER_TYPE_POINT. In such a case, the "ssid_len" is
redundant with "length" in iw_point. If we remove "ssid_len", then the
format is exactly the same as SIOCSIWESSID, which make things nice and
simple.

> Similarily, SIOCSIWAUTH/SIOCGIWAUTH uses one pair of ioctls
> to allow configuring multiple (4096) different parameters.

	It took me a while to understand how this one is supposed to
works (which means that it may need better documentation). It's a
sub-ioctl kind of thing, right ? The SET accept two 32 bit integers,
the GET accept one and return one.
	You current definition doesn't work, because you are using
IW_HEADER_TYPE_PARAM that carry only a single 32bit integer. There are
two solutions. The first is fit the IW_AUTH_INDEX in the 16 bits of
iw_param->flags. The second is to use IW_HEADER_TYPE_UINT.

	Also, all the constant used for this command should have the
IW_AUTH_* prefix (IW_CIPHER_NONE => IW_AUTH_CIPHER_NONE), so that we
can see clearly that they apply to this command. I would even go
futher and have common prefixes between request and values :
---
#define IW_AUTH_WPA_VERSION	0
---
#define IW_AUTH_WPA_VERSION_DISABLED	0
#define IW_AUTH_WPA_VERSION_WPA		1
#define IW_AUTH_WPA_VERSION_WPA2	2
---
#define IW_AUTH_CIPHER_PAIRWISE	1
#define IW_AUTH_CIPHER_GROUP	2
---
#define IW_AUTH_CIPHER_NONE	0
#define IW_AUTH_CIPHER_WEP40	1
#define IW_AUTH_CIPHER_TKIP	2
#define IW_AUTH_CIPHER_CCMP	4
#define IW_AUTH_CIPHER_WEP104	5
---
	I think this would read much better, and avoid the need to
extra documentation.

> supported_features bit field in struct iw_range will be used by the
WPA
> Supplicant to determine which modes can be used with the current
driver.

	I think that "supported_feature" is too generic a name for
what you are using it now. As there are other "supported_feature" type
of fields in iw_range (pm_capa, txpower_capa, retry_capa), I would
suggest to use a more descriptive name, such as "enc_features" or
"enc_capa".

> Comments are very much welcome, especially from other authors of
> wireless device driver. I went through the wpa_supplicant driver
> interface and tried to include everything needed here. However, I did
> not yet verify whether some of the existing driver interfaces would
> benefit from additional fields in wireless extensions.

	Well, this is where we hope the "extension" part of "wireless
extensions" works as advertised, and hopefully we can just add the
necessary features later on.

> +/* IEEE 802.11 MLME requests */
> +#define SIOCSIWMLME	0x8B30		/* request MLME operation */

	I don't see a struct for it, so I assume the format of that is
defined somewhere in the 802.11 spec ? May be worth documenting where
to look for it.

> Jouni Malinen

	I hope I did not sound too "picky", but I hope that my
suggestion are not too difficult to implement while adding some
value. Tell me what you think ;-)

	Have fun...

	Jean
