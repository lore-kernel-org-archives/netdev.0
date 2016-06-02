From: Pali =?utf-8?B?Um9ow6Fy?= <pali.rohar@gmail.com>
Subject: Re: [PATCH] r8152: Add support for setting MAC to system's Auxiliary
 MAC address
Date: Thu, 2 Jun 2016 09:46:56 +0200
Message-ID: <20160602074656.GM29844@pali>
References: <1464817844-27206-1-git-send-email-mario_limonciello@dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: hayeswang@realtek.com, LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>,
	Linux USB <linux-usb@vger.kernel.org>,
	anthony.wong@canonical.com
To: Mario Limonciello <mario_limonciello@dell.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1464817844-27206-1-git-send-email-mario_limonciello@dell.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi! As ACPI bytecode is untrusted for me and also for running kernel, w=
e
should not expect that it does not contain any bugs or other problems.
So I would propose these checks to prevent something wrong...

On Wednesday 01 June 2016 16:50:44 Mario Limonciello wrote:
> +static void set_auxiliary_addr(struct sockaddr *sa)
> +{
> +	acpi_status status;
> +	acpi_handle handle;
> +	struct acpi_buffer buffer =3D { ACPI_ALLOCATE_BUFFER, NULL };
> +	union acpi_object *obj;
> +	int i;
> +	char *ptr;
> +
> +	acpi_get_handle(NULL, "\\_SB", &handle);

Check return value of acpi_get_handle

> +	status =3D acpi_evaluate_object(handle, "AMAC", NULL, &buffer);

This is question for ACPI devs, it is not possible to call directly?

  acpi_evaluate_object(NULL, "\\_SB.AMAC", NULL, &buffer);

And what happen if we try to evaluate objects which do not exist? Does
not it show some warning or error in dmesg about non existent object?
Such errors should be silent here.

> +	obj =3D (union acpi_object *)buffer.pointer;

Check buffer.type

> +	if (ACPI_SUCCESS(status) && (obj->string.length =3D=3D 0x17)) {
> +		/* returns _AUXMAC_#AABBCCDDEEFF#
> +		 * this pulls out _AUXMAC# from start and # from end
> +		 */
> +		ptr =3D obj->string.pointer + 9;

Verify that string really contains that _AUXMAX# prefix. This is really
obscure and nonstandard format for specifying MAC address and in my
opinion it should be properly checked. Nonstandard formats can be
changed in future and we could have problems.

> +		pr_info("r8152: Using system auxiliary MAC address");

It would be great to write also mac address into that pr_info

> +		for (i =3D 0; i < 6; i++, ptr +=3D 2)
> +			sa->sa_data[i] =3D amac_ascii_to_hex(*ptr) << 4 |
> +					 amac_ascii_to_hex(*(ptr + 1));
> +	}

In case of some acpi check fails throw warning (or error).

And there is memory leak, you allocated buffer with ACPI_ALLOCATE_BUFFE=
R
but you did not free it.

> +}

And my last question is: Are really all Dell docks comes with this one
realtek chip? I'm pessimist in this, because I see how other components
(like HDD vendor, touchpad type, smardcard chips, motherboards, display
panels, wifi chips) can be different in two laptops of same Dell model.

--=20
Pali Roh=C3=A1r
pali.rohar@gmail.com
